defmodule MediaStatsRT.TopLinks.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = MediaStatsRT.TopLinks.Bucket.start_link()
    {:ok, agent: pid}
  end

  test "push and list links", %{agent: agent} do
    MediaStatsRT.TopLinks.Bucket.push(agent, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(agent, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(agent, "https://bar.com")

    assert {:ok, results} = MediaStatsRT.TopLinks.Bucket.list(agent)
    assert results == [{"https://foo.com", %{count: 2}}, {"https://bar.com", %{count: 1}}]

    assert {:ok, results} = MediaStatsRT.TopLinks.Bucket.list(agent, 2, 1)
    assert results == [{"https://bar.com", %{count: 1}}]

    assert {:ok, results} = MediaStatsRT.TopLinks.Bucket.list_by_criteria(agent, "foo")
    assert results == [{"https://foo.com", %{count: 2}}]

    assert {:ok, results} = MediaStatsRT.TopLinks.Bucket.list_by_criteria(agent, "foo", 2, 1)
    assert results == []

    assert {:ok, results} = MediaStatsRT.TopLinks.Bucket.list_by_criteria(agent, "foo", 1, 1)
    assert results == [{"https://foo.com", %{count: 2}}]
  end

  test "push invalid links should hold state", %{agent: agent} do
    MediaStatsRT.TopLinks.Bucket.push(agent, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(agent, "bar")
    MediaStatsRT.TopLinks.Bucket.push(agent, "https://foo.com")

    assert {:ok, results} = MediaStatsRT.TopLinks.Bucket.list(agent)
    assert results == [{"https://foo.com", %{count: 2}}]
  end

  test "drop and list links", %{agent: agent} do
    MediaStatsRT.TopLinks.Bucket.push(agent, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(agent, "https://foo.com")
    MediaStatsRT.TopLinks.Bucket.push(agent, "https://bar.com")
    MediaStatsRT.TopLinks.Bucket.drop(agent, "https://bar.com")

    assert {:ok, results} = MediaStatsRT.TopLinks.Bucket.list(agent)
    assert results == [{"https://foo.com", %{count: 2}}]

    MediaStatsRT.TopLinks.Bucket.drop(agent, "https://foo.com")
    assert {:ok, results} = MediaStatsRT.TopLinks.Bucket.list(agent)
    assert results == [{"https://foo.com", %{count: 1}}]

    MediaStatsRT.TopLinks.Bucket.drop(agent, "https://foo.com")
    assert {:ok, results} = MediaStatsRT.TopLinks.Bucket.list(agent)
    assert results == []
  end

  test "bucket agents have temporary restart strategy" do
    assert Supervisor.child_spec(MediaStatsRT.TopLinks.Bucket, []).restart == :temporary
  end
end
