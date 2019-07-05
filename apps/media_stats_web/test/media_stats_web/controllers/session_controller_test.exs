defmodule MediaStatsWeb.SessionControllerTest do
  use MediaStatsWeb.ConnCase

  describe "login" do
    test "GET /login", %{conn: conn} do
      conn = get(conn, "/login")
      assert html_response(conn, 200) =~ "Media stats login"
    end

    test "POST /login", %{conn: conn} do
      user_fixture(email: "iamuser@foo.com", password: "my-password")

      login_conn  = post(conn, Routes.session_path(conn, :login, %{:session => %{email: "foo.com", password: "12345"}}))

      assert html_response(login_conn, 200)
      assert login_conn.request_path == Routes.session_path(conn, :login)

      login_conn  = post(conn, Routes.session_path(conn, :login, %{:session => %{email: "test@foo.com", password: "123456"}}))
      assert html_response(login_conn, 200)
      assert login_conn.request_path == Routes.session_path(conn, :login)

      login_conn  = post(conn, Routes.session_path(conn, :login, %{:session => %{email: "iamuser@foo.com", password: "my-password"}}))
      assert redirected_to(login_conn) == Routes.dashboard_path(conn, :index)
    end
  end

  describe "logout" do
    setup %{conn: conn} do
      user = default_user()
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    end

    test "logout should remove the current from session", %{conn: conn, user: user} do
      assert conn.assigns.current_user.id == user.id
      logout_conn = delete(conn, Routes.session_path(conn, :logout))
      assert redirected_to(logout_conn) == Routes.page_path(conn, :index)
    end
  end
end
