defmodule MediaStatsRT.TopLinks.Registry do
  @moduledoc """
  Module to handle several MediaStatsRT.TopLinks.Bucket in a map
  """

  use GenServer

  @spec start_link(Keyword.t) :: {:ok, Pid.t}
  @spec lookup(Pid.t, String.t) :: {:ok, Pid.t} | :error
  @spec create(Pid.t, String.t, Keyword.t) :: {Map.t, Map.t}

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name, opts \\ []) do
    GenServer.call(server, {:create, name, opts})
  end

  @impl true
  def init(:ok) do
    names = %{}
    refs  = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _refs} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_call({:create, name, opts}, _from, {names, refs}) do
    if Map.has_key?(names, name) do
      {:reply, {names, refs}, {names, refs}}
    else
      {:ok, pid}    = DynamicSupervisor.start_child(MediaStatsRT.DynamicBucketSupervisor, {MediaStatsRT.TopLinks.Bucket, opts})
      ref           = Process.monitor(pid)
      refs          = Map.put(refs, ref, name)
      names         = Map.put(names, name, pid)

      {:reply, {names, refs}, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names        = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
