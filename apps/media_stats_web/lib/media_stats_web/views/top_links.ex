defmodule MediaStatsWeb.TopLinksView do
  use MediaStatsWeb, :view

  def render("top_links.json", %{top_links: result}) do
    map = Map.new()

    for {url, data} <- result do
      Map.put(map, url, data)
    end
  end
end