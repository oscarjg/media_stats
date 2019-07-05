defmodule MediaStats.Helpers.Strings do
  @doc """
  Make a slug for strings
  """
  def slugify(str) do
    str
    |> String.downcase()
    |> String.trim()
    |> String.replace(~r/[^\w|\s]+/u, "")
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end
