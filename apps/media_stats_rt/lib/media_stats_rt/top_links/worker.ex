defmodule MediaStatsRT.TopLinks.Worker do
  @moduledoc """
  Worker to handle links from clients

  Get client bucket and push or drop links to it
  """

  @spec push_link(String.t, String.t, Function.t, Keyword.t, pid()) :: {:ok, pid()} | {:error, String.t}
  @spec drop_link(String.t, String.t, Function.t, Keyword.t, pid()) :: {:ok, pid()} | {:error, String.t}
  @spec handle_links(String.t, String.t | List.t, String.t | List.t, Function.t, Keyword.t, pid()) :: {:ok, pid()} | {:error, String.t}

  def push_link(client_name, link, callback, client_opts \\ [], registry \\ MediaStatsRT.TopLinks.Registry) do
    Task.start_link(fn ->
      case MediaStatsRT.TopLinks.Registry.lookup(registry, client_name) do
        {:ok, bucket} ->
          MediaStatsRT.TopLinks.Bucket.push(bucket, link)
          {:ok, results} = MediaStatsRT.TopLinks.Bucket.list(bucket, client_opts[:from] || 0, client_opts[:limit] || 1000)
          callback.({:ok, results})
        :error ->
          MediaStatsRT.TopLinks.Registry.create(registry, client_name, client_opts)
          push_link(client_name, link, callback, client_opts)
      end
    end)
  end

  @doc """
  Drop link from the client bucket. If the bucket don't exists it will be created
  """
  def drop_link(client_name, link, callback, client_opts \\ [], registry \\ MediaStatsRT.TopLinks.Registry) do
    Task.start_link(fn ->
      case MediaStatsRT.TopLinks.Registry.lookup(registry, client_name) do
        {:ok, bucket} ->
          MediaStatsRT.TopLinks.Bucket.drop(bucket, link)
          {:ok, results} = MediaStatsRT.TopLinks.Bucket.list(bucket, client_opts[:from] || 0, client_opts[:limit] || 1000)
          callback.({:ok, results})
        :error ->
          callback.({:not_modified, []})
      end
    end)
  end

  @doc """
  Handle push and drop links at once
  """
  def handle_links(client_name, link_to_push, link_to_drop, callback, client_opts \\ [], registry \\ MediaStatsRT.TopLinks.Registry) do
    Task.start_link(fn ->
      case MediaStatsRT.TopLinks.Registry.lookup(registry, client_name) do
        {:ok, bucket} ->
          cond do
            is_binary(link_to_push) and is_binary(link_to_drop) ->
              push(bucket, link_to_push)
              drop(bucket, link_to_drop)
            is_list(link_to_push) and is_list(link_to_drop) ->
              for link <- link_to_push do
                push(bucket, link)
              end

              for link <- link_to_drop do
                drop(bucket, link)
              end
            true -> nil
          end

          {:ok, results} = MediaStatsRT.TopLinks.Bucket.list(bucket, client_opts[:from] || 0, client_opts[:limit] || 1000)
          callback.({:ok, results})
        :error ->
          MediaStatsRT.TopLinks.Registry.create(registry, client_name, client_opts)
          handle_links(client_name, link_to_push, link_to_drop, callback, client_opts)
      end
    end)
  end

  defp push(bucket, link) do
    MediaStatsRT.TopLinks.Bucket.push(bucket, link)
  end

  defp drop(bucket, link) do
    MediaStatsRT.TopLinks.Bucket.drop(bucket, link)
  end
end