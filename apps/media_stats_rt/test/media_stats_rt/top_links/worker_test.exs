defmodule MediaStatsRT.TopLinks.WorkerTest do
  use ExUnit.Case, async: true

  setup do
    registry_pid = start_supervised!(MediaStatsRT.TopLinks.Registry)

    MediaStatsRT.TopLinks.Registry.create(registry_pid, "foo")

    {:ok, bucket_pid} = MediaStatsRT.TopLinks.Registry.lookup(registry_pid, "foo")

    %{bucket_pid: bucket_pid, registry_pid: registry_pid}
  end

  test "push url from worker to existent client", %{bucket_pid: _, registry_pid: registry_pid} do
    MediaStatsRT.TopLinks.Worker.push_link("foo", "https://foo.com", fn results -> results end, [], registry_pid)

    assert eventually(fn ->
      case MediaStatsRT.TopLinks.Registry.lookup(registry_pid, "foo") do
        {:ok, bucket} ->
          {:ok, results } = MediaStatsRT.TopLinks.Bucket.list(bucket)
          results == [{"https://foo.com", %{count: 1}}]
        _ -> false
      end
    end)
  end

  test "push url from worker to un-existent client", %{registry_pid: registry_pid} do
    MediaStatsRT.TopLinks.Worker.push_link("client_1", "https://foo.com", fn results -> results end, [], registry_pid)

    assert eventually(fn ->
      MediaStatsRT.TopLinks.Registry.lookup(registry_pid, "client_1") !== :error
    end)
  end

  test "drop url from worker should drop links from bucket", %{bucket_pid: bucket_pid, registry_pid: registry_pid} do
    MediaStatsRT.TopLinks.Bucket.push(bucket_pid, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket_pid, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(bucket_pid, "https://foo.com")

    MediaStatsRT.TopLinks.Worker.drop_link("foo", "https://foo.com", fn results -> results end, [], registry_pid)
    MediaStatsRT.TopLinks.Worker.drop_link("foo", "https://foo.com", fn results -> results end, [], registry_pid)
    MediaStatsRT.TopLinks.Worker.drop_link("foo", "https://foo.com", fn results -> results  end, [], registry_pid)

    assert eventually(fn ->
      case MediaStatsRT.TopLinks.Registry.lookup(registry_pid, "foo") do
        {:ok, bucket} ->
          {:ok, results } = MediaStatsRT.TopLinks.Bucket.list(bucket)
          results == []
        _ -> false
      end
    end)
  end

  test "drop url from un-existent client should return not_modified", %{registry_pid: registry_pid} do
    MediaStatsRT.TopLinks.Worker.drop_link("client_1", "https://foo.com", fn result -> result end, [], registry_pid)

    assert eventually(fn -> MediaStatsRT.TopLinks.Registry.lookup(registry_pid, "client_1") === :error end)
  end

  test "handle drop and push link at one", %{registry_pid: registry_pid} do
    MediaStatsRT.TopLinks.Worker.handle_links("foo", "https://foo.com", "https://bar.com", fn results -> results end, [], registry_pid)

    assert eventually(fn ->
      case MediaStatsRT.TopLinks.Registry.lookup(registry_pid, "foo") do
        {:ok, bucket} ->
          {:ok, results } = MediaStatsRT.TopLinks.Bucket.list(bucket)
          results == [{"https://foo.com", %{count: 1}}]
        _ -> false
      end
    end)
  end

  test "handle several drop and push link at one", %{registry_pid: registry_pid} do
    links_to_push = [
      "https://foo.com",
      "https://foo.com",
      "https://bar.com",
      "https://bar.com",
      "https://bar.com",
    ]

    links_to_drop = [
      "https://bar.com"
    ]

    MediaStatsRT.TopLinks.Worker.handle_links("foo", links_to_push, links_to_drop, fn results -> results end, [], registry_pid)

    assert eventually(fn ->
      case MediaStatsRT.TopLinks.Registry.lookup(registry_pid, "foo") do
        {:ok, bucket} ->
          {:ok, results } = MediaStatsRT.TopLinks.Bucket.list(bucket)
          results == [{"https://bar.com", %{count: 2}}, {"https://foo.com", %{count: 2}}]
        _ -> false
      end
    end)
  end

  defp eventually(func) do
    if func.() do
      true
    else
      Process.sleep(10)
      eventually(func)
    end
  end
end