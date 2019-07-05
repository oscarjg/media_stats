defmodule MediaStatsRT.TopLinks.Bucket do
  @moduledoc """
  Agent to save top links using MediaStatsRT.LinksBucket
  """

  use Agent, restart: :temporary

  @spec push(Pid.t, String.t) :: {:ok, Enum.t}
  @spec drop(Pid.t, String.t) :: {:ok, Enum.t}
  @spec list(Pid.t) :: {:ok, Enum.t}
  @spec list(Pid.t, Integer.t, Integer.t) :: {:ok, Enum.t}
  @spec list_by_criteria(Pid.t, String.t) :: {:ok, Enum.t}
  @spec list_by_criteria(Pid.t, String.t, Integer.t, Integer.t) :: {:ok, Enum.t}

  def start_link(opts \\ []) do
    {:ok, bucket } = MediaStatsRT.LinksBucket.init(opts)
    Agent.start_link(fn -> bucket end)
  end

  def list(server) do
    Agent.get(server, fn state ->
      {:ok, _bucket, results} = MediaStatsRT.LinksBucket.list(state)
      {:ok, results}
    end)
  end

  def list(server, from, to) when is_integer(from) and is_integer(to) do
    Agent.get(server, fn state ->
      {:ok, _bucket, results} = MediaStatsRT.LinksBucket.list(state, from, to)
      {:ok, results}
    end)
  end

  def list_by_criteria(server, criteria) when is_binary(criteria) do
    Agent.get(server, fn state ->
      {:ok, _bucket, results} = MediaStatsRT.LinksBucket.list_by_criteria(state, criteria)
      {:ok, results}
    end)
  end

  def list_by_criteria(server, criteria, from, to) when is_binary(criteria) and is_integer(from) and is_integer(to) do
    Agent.get(server, fn state ->
      {:ok, _bucket, results} = MediaStatsRT.LinksBucket.list_by_criteria(state, criteria, from, to)
      {:ok, results}
    end)
  end

  def push(server, link) when is_binary(link) do
    Agent.get_and_update(server, fn state ->
      case MediaStatsRT.LinksBucket.push(state, link) do
        {:ok, bucket} ->
          {state, bucket}
        _ ->
          {state, state}
      end
    end)
  end

  def drop(server, link) when is_binary(link) do
    Agent.get_and_update(server, fn state ->
      case MediaStatsRT.LinksBucket.drop(state, link) do
        {:ok, bucket} ->
          {state, bucket}
        _ ->
          {state, state}
      end
    end)
  end
end
