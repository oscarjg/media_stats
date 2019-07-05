defmodule MediaStatsWeb.PageController do
  use MediaStatsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
