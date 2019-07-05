defmodule MediaStatsWeb.ApplicationController do
  use MediaStatsWeb, :controller

  alias MediaStats.Accounts.Application
  alias MediaStats.Accounts

  def create(conn, %{"application" => application_params}, current_user) do
    case MediaStats.Accounts.create_application(current_user, add_app_key(application_params)) do
      {:ok, _application} ->
        conn
        |> redirect(to: Routes.dashboard_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "create.html", changeset: changeset)
    end
  end

  def new(conn, _params, _current_user) do
    changeset = Application.registration_changeset(%Application{})
    render(conn, "create.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "application" => application_params}, current_user) do
    application = Accounts.get_user_application!(current_user, id)

    case MediaStats.Accounts.update_application(application, application_params) do
      {:ok, _application} ->
        conn
        |> redirect(to: Routes.dashboard_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}, current_user) do
    application = Accounts.get_user_application!(current_user, id)
    changeset = Application.changeset(application)
    render(conn, "edit.html", application: application, changeset: changeset)
  end

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  defp add_app_key(application_params) do
    credentials = Map.put_new(application_params["credential"], "app_key", Ecto.UUID.generate())
    Map.update!(application_params, "credential", fn _ -> credentials end)
  end
end
