defmodule MediaStatsWeb.TopLinksRTChannel do
  use MediaStatsWeb, :channel
  alias MediaStatsWeb.Presence

  def join("rt:top-links:" <> _app_key, params, socket) do
    limit   = params["limit"] || 1000
    tracker = params["tracker"] || nil

    socket =
      socket
      |> assign(:limit, limit)
      |> assign(:tracker, tracker)


    send(self(), {:after_join, params})

    {:ok, fetch_initial_value(socket.assigns.app_key, limit), socket}
  end

  def terminate({:shutdown, _}, socket) do

    case socket.assigns.tracker do
      %{"current_url" => current_url} ->
        task = MediaStatsRT.TopLinks.Worker.drop_link_async(
          socket.assigns.app_key,
          current_url,
          limit: socket.assigns.limit || 1000
        )

        results = Task.await(task)
        broadcast_top_links(socket, results, "link_dropped")
      _ -> true
    end
  end

  def handle_in("push_link", params, socket) do
    MediaStatsRT.TopLinks.Worker.push_link(
      socket.assigns.app_key,
      params["link"],
      fn {:ok, results} -> broadcast_top_links(socket, results, "link_pushed") end,
      limit: socket.assigns.limit || 1000
    )

    {:reply, :ok, socket}
  end

  def handle_info({:after_join, params}, socket) do
    push(socket, "presence_state", Presence.list(socket))

    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second)),
      params: params
    })

    {:noreply, socket}
  end

  defp broadcast_top_links(socket, links, event_name) do
    broadcast!(
      socket,
      event_name,
      %{
        top_links: Phoenix.View.render_one(links, MediaStatsWeb.TopLinksView, "top_links.json")
      }
    )
  end

  defp fetch_initial_value(app_key, limit) do
    case MediaStatsRT.TopLinks.Registry.lookup(MediaStatsRT.TopLinks.Registry, app_key) do
      {:ok, bucket} ->
        {:ok, results} = MediaStatsRT.TopLinks.Bucket.list(bucket, 0, limit)
        Phoenix.View.render_one(results, MediaStatsWeb.TopLinksView, "top_links.json")
        %{
          top_links: Phoenix.View.render_one(results, MediaStatsWeb.TopLinksView, "top_links.json")
        }
      :error ->
        MediaStatsRT.TopLinks.Registry.create(MediaStatsRT.TopLinks.Registry, app_key)
        fetch_initial_value(app_key, limit)
    end
  end
end