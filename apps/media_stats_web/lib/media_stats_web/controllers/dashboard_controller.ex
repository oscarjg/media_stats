defmodule MediaStatsWeb.DashboardController do
  use MediaStatsWeb, :controller

  def index(conn, _params, current_user) do
    applications = MediaStats.Accounts.list_user_applications(current_user)
    render(conn, "index.html", applications: applications)
  end

  def pusher(conn, _params, _current_user) do
    render(conn, "pusher.html")
  end

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end
end
