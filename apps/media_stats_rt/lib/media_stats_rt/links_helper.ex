defmodule MediaStatsRT.LinksHelper do
  @moduledoc """
  Helper module related with links
  """

  @spec generate_unique(String.t) :: String.t

  @doc "Clean params from link given unique links"
  def generate_unique(url) when is_binary(url) do
    url
    |> String.replace(~r/(\?|#).+/u, "")
  end
end
