defmodule MediaStatsWeb.UserController do
  use MediaStatsWeb, :controller
  alias MediaStats.Accounts.User

  def sign_up(conn, %{"user" => user_params}) do
    case MediaStats.Accounts.create_registered_user(user_params) do
      {:ok, user} ->
        conn
        |> MediaStatsWeb.Auth.login(user)
        |> put_flash(:info, "A new user has been created!")
        |> redirect(to: Routes.dashboard_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "sign_up.html", changeset: changeset)
    end
  end

  def sign_up(conn, _params) do
    changeset = User.registration_changeset(%User{}, %{})
    render(conn, "sign_up.html", changeset: changeset)
  end
end
