defmodule MediaStatsRT.TopLinks.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(MediaStatsRT.TopLinks.Registry)
    %{registry: registry}
  end

  test "add bucket to the registry", %{registry: registry} do
    assert {_buckets, _refs} = MediaStatsRT.TopLinks.Registry.create(registry, "client_1")
    assert {:ok, _pid}       = MediaStatsRT.TopLinks.Registry.lookup(registry, "client_1")
  end

  test "lookup un-registered buckets should return error", %{registry: registry} do
    assert MediaStatsRT.TopLinks.Registry.lookup(registry, "client_1") === :error
  end

  test "stop agents should remove registered buckets from registry", %{registry: registry} do
    MediaStatsRT.TopLinks.Registry.create(registry, "client_1")
    MediaStatsRT.TopLinks.Registry.create(registry, "client_2")

    {:ok, pid_client_1} = MediaStatsRT.TopLinks.Registry.lookup(registry, "client_1")
    Agent.stop(pid_client_1)

    assert MediaStatsRT.TopLinks.Registry.lookup(registry, "client_1") === :error
    assert assert {:ok, _pid} = MediaStatsRT.TopLinks.Registry.lookup(registry, "client_2")
  end

  test "crash agents should remove registered buckets from registry", %{registry: registry} do
    MediaStatsRT.TopLinks.Registry.create(registry, "client_1")
    MediaStatsRT.TopLinks.Registry.create(registry, "client_2")

    {:ok, pid_client_1} = MediaStatsRT.TopLinks.Registry.lookup(registry, "client_1")
    Agent.stop(pid_client_1, :shutdown)

    assert MediaStatsRT.TopLinks.Registry.lookup(registry, "client_1") === :error
    assert assert {:ok, _pid} = MediaStatsRT.TopLinks.Registry.lookup(registry, "client_2")
  end
end