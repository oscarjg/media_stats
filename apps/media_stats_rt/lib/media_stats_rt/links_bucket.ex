defmodule MediaStatsRT.LinksBucket do
  @moduledoc """
  Module to store and list links

  ## Examples
    {:ok, bucket} = MediaStatsRT.LinksBucket.start
    {:ok, bucket} = MediaStatsRT.LinksBucket.push(bucket, "https://foo.com")
    {:ok, bucket} = MediaStatsRT.LinksBucket.drop(bucket, "https://foo.com")
    {:ok, bucket, results} = MediaStatsRT.LinksBucket.list(bucket)
    {:ok, bucket, results} = MediaStatsRT.LinksBucket.list_by_criteria(bucket, "foo")
  """

  @spec init(List.t) :: {:ok, Links.t}
  @spec push(Links.t, String.t) :: {:ok, Links.t} | {:error, String.t}
  @spec drop(Links.t, String.t) :: {:ok, Links.t} | {:error, String.t}
  @spec list(Links.t) :: {:ok, Links.t, Enum.t}
  @spec list(Links.t, Integer.t, Integer.t) :: {:ok, Links.t, Enum.t}
  @spec list_by_criteria(Links.t, String.t) :: {:ok, Links.t, Enum.t}
  @spec list_by_criteria(Links.t, String.t, Integer.t, Integer.t) ::
          {Atom.t, Links.t, Map.t}

  defmodule Links do
    defstruct links: %{}, limit: 1000
  end

  @doc """
  Initializes a new bucket struct
  """
  def init(opts) when is_list(opts) do
    bucket = cond do
      Keyword.has_key?(opts, :limit) -> %Links{limit: opts[:limit]}
      true -> %Links{}
    end

    {:ok, bucket}
  end

  @doc """
  Push link into the bucket
  """
  def push(bucket = %Links{}, link_to_add) when is_binary(link_to_add) do
    case MediaStatsRT.LinksValidator.validate(link_to_add) do
      {:ok, _} ->
        links =
          Map.update(bucket.links, link_to_add, %{count: 1}, fn link ->
            %{count: link.count + 1}
          end)

        {:ok, Map.update!(bucket, :links, fn _ -> links end)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Drop link from the bucket
  """
  def drop(bucket = %Links{}, link_to_drop) when is_binary(link_to_drop) do
    case MediaStatsRT.LinksValidator.validate(link_to_drop) do
      {:ok, _} ->
        {_, links} =
          Map.get_and_update(bucket.links, link_to_drop, fn current_value ->
            case current_value do
              %{count: counter} ->
                cond do
                  counter - 1 == 0 -> :pop
                  true -> {current_value, %{count: counter - 1}}
                end

              _ ->
                :pop
            end
          end)

        {:ok, Map.update!(bucket, :links, fn _ -> links end)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  List stored links by count order
  """
  def list(bucket = %Links{}) do
    results =
      bucket.links
      |> Map.to_list()
      |> Enum.sort(fn {_, result_a}, {_, result_b} ->
        result_a.count >= result_b.count
      end)

    {:ok, bucket, results}
  end

  @doc """
  List stored links by count order with pagination
  """
  def list(bucket = %Links{}, from, to) when is_number(from) and is_number(to) do
    {_, _, results} = list(bucket)

    {:ok, bucket, pagination(results, from, to)}
  end

  @doc """
  List stored links by count order and by criteria filtering
  """
  def list_by_criteria(bucket, criteria) when is_binary(criteria) do
    results =
      bucket.links
      |> Map.to_list()
      |> Enum.filter(fn {link, _counter} ->
        case Regex.compile(criteria) do
          {:ok, regex} ->
            String.match?(link, regex)

          {:error, _} ->
            false
        end
      end)
      |> Enum.sort(fn {_, counter_a}, {_, counter_b} -> counter_a.count >= counter_b.count end)

    {:ok, bucket, results}
  end

  @doc """
  List stored links by count order and by criteria filtering with pagination
  """
  def list_by_criteria(bucket, criteria, from, to)
      when is_binary(criteria) and is_number(from) and is_number(to) do
    {_, _, results} = list_by_criteria(bucket, criteria)

    {:ok, bucket, pagination(results, from, to)}
  end

  defp pagination(results, from, to) do
    cond do
      from <= 0 -> Enum.slice(results, 0, to)
      from == 1 -> Enum.slice(results, 0, from * to)
      true -> Enum.slice(results, (from - 1) * to, to)
    end
  end
end
