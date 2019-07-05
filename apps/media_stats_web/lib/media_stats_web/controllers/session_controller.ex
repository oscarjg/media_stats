defmodule MediaStatsWeb.SessionController do
  use MediaStatsWeb, :controller

  def login(conn, %{"session" => %{"email" => email, "password" => pass}}) do
    case MediaStatsWeb.Auth.login_by_email_and_pass(conn, email, pass) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.dashboard_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid user or password")
        |> render("login.html")
    end
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def logout(conn, _params) do
    conn
    |> MediaStatsWeb.Auth.logout()
    |> put_flash(:info, "See you soon!")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
