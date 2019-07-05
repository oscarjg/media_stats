defmodule MediaStatsWeb.AuthTest do
  use MediaStatsWeb.ConnCase

  alias MediaStatsWeb.Auth
  alias MediaStats.Accounts.User

  setup(%{conn: conn}) do
    conn =
      conn
      |> bypass_through(MediaStatsWeb.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "authenticated user halts when connection has not have a user", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, nil)
      |> Auth.authenticate_user([])

    assert conn.halted
  end

  test "authenticated user continues when connection has a user", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %User{})
      |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login a user", %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%User{id: 1234})
      |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 1234
  end

  test "logout a user", %{conn: conn} do
    logout_conn =
      conn
      |> assign(:current_user, %User{id: 1234})
      |> put_session(:user_id, 1234)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")

    refute get_session(next_conn, :user_id)
  end

  test "call plug directly must assign current user on connection", %{conn: conn} do
    %{id: user_id} = default_user()

    conn =
      conn
      |> put_session(:user_id, user_id)
      |> Auth.call(Auth.init([]))

    assert conn.assigns.current_user.id == user_id
  end

  test "call plug directly without session user_id key assigned should return nil", %{conn: conn} do
    conn =
      conn
      |> Auth.call(Auth.init([]))

    assert conn.assigns.current_user == nil
  end

  test "login by email and pass should return a user", %{conn: conn} do
    %{id: id, credential: %{email: email, password: pass}} = default_user()

    assert {:ok, login_conn} =
             conn
             |> Auth.login_by_email_and_pass(email, pass)

    assert get_session(login_conn, :user_id)  == id
    assert login_conn.assigns.current_user.id == id
  end

  test "login with wrong email should be return not found", %{conn: conn} do
    assert {:error, :not_found, _conn} =
             conn
             |> Auth.login_by_email_and_pass("foo_invalid@g.com", "123456")
  end

  test "login with wrong password should be return unauthorized", %{conn: conn} do
    user_fixture(%{email: "foo@server.com", passoword: "123456"})

    assert {:error, :unauthorized, _conn} =
             conn
             |> Auth.login_by_email_and_pass("foo@server.com", "wrong_pass")
  end

  test "authenticated user has a token", %{conn: conn} do
    %{id: user_id} = default_user()

    conn =
      conn
      |> put_session(:user_id, user_id)
      |> Auth.call(Auth.init([]))

    assert conn.assigns.user_token != ""
  end
end