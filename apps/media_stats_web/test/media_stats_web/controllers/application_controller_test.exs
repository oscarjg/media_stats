defmodule MediaStatsWeb.ApplicationControllerTest do
  use MediaStatsWeb.ConnCase

  describe "with non logged user" do
    test "application pages should not be public so should we get a redirect response", %{conn: conn} do
      get_routes = [
        get(conn, Routes.application_path(conn, :new)),
        get(conn, Routes.application_path(conn, :edit, 123))
      ]

      for conn <- get_routes do
        assert html_response(conn, 302)
        assert conn.halted
      end
    end
  end

  describe "with logged in users" do
    setup %{conn: conn} do
      user = default_user()
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    end

    @invalid_application %{
      "name" => "",
      "credential" => %{
        "allowed_hosts" => "127.0.0.1"
      }
    }

    @valid_application %{
      "name" => "Foo App",
      "credential" => %{
        "app_key" => "foo-key",
        "allowed_hosts" => "127.0.0.1"
      }
    }

    test "GET /applications/create", %{conn: conn} do
      conn = get(conn, Routes.application_path(conn, :new))
      assert html_response(conn, 200) =~ "Create your new application"
    end

    test "POST /applications/create", %{conn: conn} do
      client_conn  = post(conn, Routes.application_path(conn, :create, %{:application => @invalid_application}))
      assert html_response(client_conn, 200) =~ "Create your new application"

      client_conn  = post(conn, Routes.application_path(conn, :create, %{:application => @valid_application}))
      assert redirected_to(client_conn) ==  Routes.dashboard_path(conn, :index)
    end

    test "edit a user application should return 200", %{conn: conn, user: user} do
      {:ok, app}  = application_fixture(user)
      conn = get(conn, Routes.application_path(conn, :edit, app.id))
      assert html_response(conn, 200) =~ app.name
    end

    test "update a user application should return 200", %{conn: conn, user: user} do
      {:ok, app}  = application_fixture(user)

      valid_update_application = %{
        "name" => "Bar App",
        "credential" => %{
          "id" => app.credential.id,
          "allowed_hosts" => "localhost"
        }
      }

      conn = put(conn, Routes.application_path(conn, :update, app.id, %{:application => valid_update_application}))
      assert redirected_to(conn) ==  Routes.dashboard_path(conn, :index)
      application = MediaStats.Accounts.get_user_application!(user, app.id)
      assert application.name == "Bar App"
      assert application.credential.allowed_hosts == "localhost"
    end
  end
end
