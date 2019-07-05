defmodule MediaStatsWeb.DashboardControllerTest do
  use MediaStatsWeb.ConnCase

  describe "with non logged user" do
    test "dashboard pages should not be public so should we get a redirect response", %{conn: conn} do
      get_routes = [
        get(conn, Routes.dashboard_path(conn, :index))
      ]

      for conn <- get_routes do
        assert html_response(conn, 302)
        assert conn.halted
      end
    end
  end

  describe "with logged in users" do
    setup %{conn: conn} do
      {:ok, user} = user_fixture()
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    end

    test "GET /dashboard", %{conn: conn, user: user} do
      application_fixture(user, %{name: "App 1"})
      application_fixture(user, %{name: "App 2"})

      {:ok, user_1} = user_fixture()
      application_fixture(user_1, %{name: "App 3"})
      application_fixture(user_1, %{name: "App 4"})

      conn = get(conn, Routes.dashboard_path(conn, :index))
      assert html_response(conn, 200)
      assert String.contains?(conn.resp_body, "App 1")
      assert String.contains?(conn.resp_body, "App 2")
      refute String.contains?(conn.resp_body, "App 3")
      refute String.contains?(conn.resp_body, "App 4")
    end
  end
end
