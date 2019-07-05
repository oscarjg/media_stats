defmodule MediaStatsRT.TopLinks.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    children = [
      {DynamicSupervisor, name: MediaStatsRT.DynamicBucketSupervisor, strategy: :one_for_one},
      {MediaStatsRT.TopLinks.Registry, name: MediaStatsRT.TopLinks.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end