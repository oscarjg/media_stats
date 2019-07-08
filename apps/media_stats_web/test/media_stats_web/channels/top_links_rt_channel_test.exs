defmodule MediaStatsWeb.ApplicationSocketTest do
  use MediaStatsWeb.ChannelCase

  alias MediaStatsWeb.ApplicationSocket

  setup do
    {:ok, user} = user_fixture()
    {:ok, app}  = application_fixture(user, allowed_hosts: "127.0.0.1")

    app_key = app.credential.app_key

    {:ok, socket} = connect(ApplicationSocket, %{"app_key" => app_key}, %{:uri => %URI{host: "127.0.0.1"}})

    case MediaStatsRT.TopLinks.Registry.lookup(MediaStatsRT.TopLinks.Registry, app_key) do
      {:ok, pid}
        -> Agent.stop(pid, :shutdown)
      :error
        -> true
    end

    {:ok, socket: socket, bucket_name: app_key}
  end

  test "push new links to non existent bucket", %{socket: socket, bucket_name: bucket_name} do
    {:ok, _, socket} = subscribe_and_join(socket, "rt:top-links:" <> bucket_name, %{})

    ref = push socket, "push_link", %{link: "https://foo.com"}
    assert_reply ref, :ok, %{}
    assert_broadcast "link_pushed", %{top_links: links}

    ref = push socket, "push_link", %{link: "https://foo.com"}
    assert_reply ref, :ok, %{}
    assert_broadcast "link_pushed", %{top_links: links}

    ref = push socket, "push_link", %{link: "https://foo.com"}
    assert_reply ref, :ok, %{}
    assert_broadcast "link_pushed", %{top_links: links}

    ref = push socket, "push_link", %{link: "https://bar.com"}
    assert_reply ref, :ok, %{}
    assert_broadcast "link_pushed", %{top_links: links}

    assert {:ok, %{"https://foo.com" => %{count: 3}}}= Enum.fetch(links,0)
    assert {:ok, %{"https://bar.com" => %{count: 1}}}= Enum.fetch(links,1)
  end

  test "push links on existent bucket", %{socket: socket, bucket_name: bucket_name} do
    bucket = create_bucket(bucket_name)

    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://bar.com")

    {:ok, _, socket} = subscribe_and_join(socket, "rt:top-links:" <> bucket_name, %{})
    ref = push socket, "push_link", %{link: "https://foo.com"}
    assert_reply ref, :ok, %{}
    assert_broadcast "link_pushed", %{top_links: links}

    assert {:ok, %{"https://foo.com" => %{count: 4}}}= Enum.fetch(links,0)
    assert {:ok, %{"https://bar.com" => %{count: 1}}}= Enum.fetch(links,1)
  end

  test "drop current link on exits", %{socket: socket, bucket_name: bucket_name} do
    bucket = create_bucket(bucket_name)

    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://foo.com")

    {:ok, _, socket} = subscribe_and_join(socket, "rt:top-links:" <> bucket_name, %{
      "tracker" => %{"current_url" => "https://foo.com"}
    })

    assert MediaStatsRT.TopLinks.Bucket.list(bucket) == {:ok, [{"https://foo.com", %{count: 2}}]}

    Process.flag(:trap_exit, true)
    close(socket)

    assert_broadcast "link_dropped", %{top_links: _links}

    assert MediaStatsRT.TopLinks.Bucket.list(bucket) == {:ok, [{"https://foo.com", %{count: 1}}]}
  end

  defp create_bucket(name) do
    MediaStatsRT.TopLinks.Registry.create(MediaStatsRT.TopLinks.Registry, name)
    {:ok, bucket} = MediaStatsRT.TopLinks.Registry.lookup(MediaStatsRT.TopLinks.Registry, name)
    bucket
  end
end