defmodule MediaStatsWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias MediaStatsWeb.Router.Helpers, as: Routes
  alias MediaStatsWeb.Plug.Auth

  def init(opts), do: Auth.init(opts)

  def call(conn, opts) do
    Auth.call(conn, opts)
  end

  def login(conn, user) do
    conn
    |> Auth.put_current_user_and_user_token(user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def login_by_email_and_pass(conn, email, given_pass) do
    case MediaStats.Accounts.authenticate_user_by_email_and_password(email, given_pass) do
      {:ok, user} -> {:ok, login(conn, user)}
      {:error, :unauthorized} -> {:error, :unauthorized, conn}
      {:error, :not_found} -> {:error, :not_found, conn}
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end