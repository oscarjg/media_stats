defmodule MediaStatsRT.LinksBucketTest do
  use ExUnit.Case, async: true

  doctest MediaStatsRT.LinksBucket

  alias MediaStatsRT.LinksBucket

  describe "success use cases" do
    test "bucket initializations" do
      assert {:ok, %LinksBucket.Links{links: %{}, limit: 1000}} = LinksBucket.init([])
      assert {:ok, %LinksBucket.Links{links: %{}, limit: 2000}} = LinksBucket.init(limit: 2000)
      assert {:ok, %LinksBucket.Links{links: %{}, limit: 1000}} = LinksBucket.init(unexpected_key: "foo")
    end

    test "push link to buckets" do
      {:ok, bucket} = LinksBucket.init([])
      {:ok, bucket} = LinksBucket.push(bucket, "http://foo.com")
      {:ok, bucket} = LinksBucket.push(bucket, "http://foo.com")
      {:ok, bucket} = LinksBucket.push(bucket, "http://bar.com")

      assert bucket.links == %{"http://bar.com" => %{count: 1}, "http://foo.com" => %{count: 2}}
    end

    test "push invalid links should return and :error" do
      {:ok, bucket} = LinksBucket.init([])
      assert {:error, _reason} = LinksBucket.push(bucket, "foo.com")
      assert {:error, _reason} = LinksBucket.push(bucket, "www.foo")
      assert {:error, _reason} = LinksBucket.push(bucket, "foo")
    end

    test "drop link from the buckets" do
      {:ok, bucket} = LinksBucket.init([])
      {:ok, bucket} = LinksBucket.push(bucket, "http://foo.com")
      {:ok, bucket} = LinksBucket.push(bucket, "http://foo.com")
      {:ok, bucket} = LinksBucket.push(bucket, "http://bar.com")
      {:ok, bucket} = LinksBucket.drop(bucket, "http://foo.com")
      {:ok, bucket} = LinksBucket.drop(bucket, "http://bar.com")

      assert bucket.links == %{"http://foo.com" => %{count: 1}}
    end

    test "drop invalid links should return and :error" do
      {:ok, bucket} = LinksBucket.init([])
      assert {:error, _reason} = LinksBucket.drop(bucket, "foo.com")
      assert {:error, _reason} = LinksBucket.drop(bucket, "www.foo")
      assert {:error, _reason} = LinksBucket.drop(bucket, "foo")
    end

    test "drop not found key should un-change the bucket" do
      {:ok, bucket} = LinksBucket.init([])
      {:ok, bucket} = LinksBucket.push(bucket, "http://foo.com")
      {:ok, bucket} = LinksBucket.drop(bucket, "http://bar.com")

      assert bucket.links == %{"http://foo.com" => %{count: 1}}
    end

    test "drop last link should return a clean map" do
      {:ok, bucket} = LinksBucket.init(limit: 20)
      {:ok, bucket} = LinksBucket.push(bucket, "http://foo.com")
      {:ok, bucket} = LinksBucket.drop(bucket, "http://foo.com")

      assert bucket == %LinksBucket.Links{links: %{}, limit: 20}
    end

    test "list bucket should return an ordered list" do
      {:ok, bucket} = LinksBucket.init([])
      {:ok, bucket} = LinksBucket.push(bucket, "http://foo.com")
      {:ok, bucket} = LinksBucket.push(bucket, "http://foo.com")
      {:ok, bucket} = LinksBucket.push(bucket, "http://bar.com")

      assert {:ok, _bucket, results} = LinksBucket.list(bucket)
      assert results == [{"http://foo.com", %{count: 2}}, {"http://bar.com", %{count: 1}}]

      assert {:ok, _bucket, results} = LinksBucket.list(bucket, 1, 1)
      assert results == [{"http://foo.com", %{count: 2}}]

      assert {:ok, _bucket, results} = LinksBucket.list(bucket, 1, 5)
      assert results == [{"http://foo.com", %{count: 2}}, {"http://bar.com", %{count: 1}}]

      assert {:ok, _bucket, results} = LinksBucket.list(bucket, 2, 1)
      assert results == [{"http://bar.com", %{count: 1}}]

      assert {:ok, _bucket, results} = LinksBucket.list(bucket, 2, 5)
      assert results == []
    end

    test "list with criteria bucket should return an ordered list" do
      {:ok, bucket} = LinksBucket.init([])
      {:ok, bucket} = LinksBucket.push(bucket, "http://foo.com")
      {:ok, bucket} = LinksBucket.push(bucket, "http://foo.com")
      {:ok, bucket} = LinksBucket.push(bucket, "http://bar.com")

      assert {:ok, _bucket, results} = LinksBucket.list_by_criteria(bucket, "")
      assert results == [{"http://foo.com", %{count: 2}}, {"http://bar.com", %{count: 1}}]

      assert {:ok, _bucket, results} = LinksBucket.list_by_criteria(bucket, "no-match")
      assert results == []

      assert {:ok, _bucket, results} = LinksBucket.list_by_criteria(bucket, "foo|bar")
      assert results == [{"http://foo.com", %{count: 2}}, {"http://bar.com", %{count: 1}}]

      assert {:ok, _bucket, results} = LinksBucket.list_by_criteria(bucket, "bar")
      assert results == [{"http://bar.com", %{count: 1}}]

      assert {:ok, _bucket, results} = LinksBucket.list_by_criteria(bucket, "foo|bar", 1, 1)
      assert results == [{"http://foo.com", %{count: 2}}]

      assert {:ok, _bucket, results} = LinksBucket.list_by_criteria(bucket, "foo|bar", 1, 5)
      assert results == [{"http://foo.com", %{count: 2}}, {"http://bar.com", %{count: 1}}]
    end
  end
end
