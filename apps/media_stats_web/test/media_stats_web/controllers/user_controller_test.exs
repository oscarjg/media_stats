defmodule MediaStatsWeb.UserControllerTest do
  use MediaStatsWeb.ConnCase

  describe "user registration" do
    @invalid_user_1 %{:name => "", :credential => %{"email" => "test@foo.com", "password" => "12345"}}
    @invalid_user_2 %{:name => "", :credential => %{"email" => "test@foo.com", "password" => "12345"}}
    @valid_user   %{:name => "Foo Bar", :credential => %{"email" => "test@foo.com", "password" => "123456"}}

    test "GET /sign-up", %{conn: conn} do
      conn = get(conn, "/sign-up")
      assert html_response(conn, 200) =~ "Welcome to media stats"
    end

    test "POST /sign-up", %{conn: conn} do
      client_conn  = post(conn, Routes.user_path(conn, :sign_up, %{:user => @invalid_user_1}))
      assert html_response(client_conn, 200) =~ "Welcome to media stats"

      client_conn  = post(conn, Routes.user_path(conn, :sign_up, %{:user => @invalid_user_2}))
      assert html_response(client_conn, 200) =~ "Welcome to media stats"

      client_conn  = post(conn, Routes.user_path(conn, :sign_up, %{:user => @valid_user}))
      assert redirected_to(client_conn) == Routes.dashboard_path(conn, :index)
    end
  end
end
