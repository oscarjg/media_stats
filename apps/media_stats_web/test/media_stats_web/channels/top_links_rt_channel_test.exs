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

    links_to_push = [
      "https://foo.com",
      "https://foo.com",
      "https://foo.com",
      "https://bar.com"
    ]

    links_to_drop = []

    ref = push socket, "push_links", %{links_to_push: links_to_push, links_to_drop: links_to_drop}
    assert_reply ref, :ok, %{}
    assert_broadcast "pushed_links", %{top_links: links}

    assert {:ok, %{"https://foo.com" => %{count: 3}}}= Enum.fetch(links,0)
    assert {:ok, %{"https://bar.com" => %{count: 1}}}= Enum.fetch(links,1)
  end

  test "push links on existent bucket", %{socket: socket, bucket_name: bucket_name} do
    bucket = create_bucket(bucket_name)

    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://bar.com")

    links_to_push = [
      "https://foo.com",
      "https://foo.com",
      "https://foo.com",
      "https://bar.com"
    ]

    links_to_drop = [
      "https://bar.com"
    ]

    {:ok, _, socket} = subscribe_and_join(socket, "rt:top-links:" <> bucket_name, %{})
    ref = push socket, "push_links", %{links_to_push: links_to_push, links_to_drop: links_to_drop}
    assert_reply ref, :ok, %{}
    assert_broadcast "pushed_links", %{top_links: links}
    assert {:ok, %{"https://foo.com" => %{count: 6}}}= Enum.fetch(links,0)
    assert {:ok, %{"https://bar.com" => %{count: 1}}}= Enum.fetch(links,1)
  end

  test "drop links on existent bucket ", %{socket: socket, bucket_name: bucket_name} do
    bucket = create_bucket(bucket_name)

    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket, "https://bar.com")

    links_to_push = []

    links_to_drop = [
      "https://foo.com",
      "https://bar.com"
    ]

    {:ok, _, socket} = subscribe_and_join(socket, "rt:top-links:" <> bucket_name, %{})
    ref = push socket, "push_links", %{links_to_push: links_to_push, links_to_drop: links_to_drop}
    assert_reply ref, :ok, %{}
    assert_broadcast "pushed_links", %{top_links: links}
    assert {:ok, %{"https://foo.com" => %{count: 2}}}= Enum.fetch(links,0)
    assert :error = Enum.fetch(links,1)
  end

  defp create_bucket(name) do
    MediaStatsRT.TopLinks.Registry.create(MediaStatsRT.TopLinks.Registry, name)
    {:ok, bucket} = MediaStatsRT.TopLinks.Registry.lookup(MediaStatsRT.TopLinks.Registry, name)
    bucket
  end
end