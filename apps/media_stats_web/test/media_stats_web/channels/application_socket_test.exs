defmodule MediaStatsWeb.Channels.ApplicationSocketTest do
  use MediaStatsWeb.ChannelCase, async: true

  alias MediaStatsWeb.ApplicationSocket

  test "socket authentication with valid credentials" do
    {:ok, user} = user_fixture()
    {:ok, app}  = application_fixture(user, allowed_hosts: "127.0.0.1")

    app_key = app.credential.app_key
    assert {:ok, socket} = connect(ApplicationSocket, %{"app_key" => app_key}, %{:uri => %URI{host: "127.0.0.1"}})
    assert socket.assigns.user_id == user.id
    assert socket.assigns.application_id == app.id
    assert socket.assigns.app_key == app_key
  end

  test "socket authentication with invalid credentials" do
    {:ok, user} = user_fixture()
    {:ok, app}  = application_fixture(user, allowed_hosts: "127.0.0.1")

    assert :error = connect(ApplicationSocket, %{"app_key" => app.credential.app_key}, %{:uri => %URI{host: ""}})
    assert :error = connect(ApplicationSocket, %{"app_key" => app.credential.app_key}, %{:uri => %URI{host: "192.168.1.1"}})
    assert :error = connect(ApplicationSocket, %{"app_key" => "invalid-app-id"})
    assert :error = connect(ApplicationSocket, %{})
  end

  test "socket authentication from config host should allowing access without hosts" do
    {:ok, user} = user_fixture()
    {:ok, app}  = application_fixture(user, allowed_hosts: "127.0.0.1")

    assert :error = connect(ApplicationSocket, %{"app_key" => app.credential.app_key}, %{:uri => %URI{host: ""}})
    assert :error = connect(ApplicationSocket, %{"app_key" => app.credential.app_key}, %{:uri => %URI{host: "192.168.1.1"}})
    assert :error = connect(ApplicationSocket, %{"app_key" => "invalid-app-id"})
    assert :error = connect(ApplicationSocket, %{})
    assert {:ok, socket} = connect(ApplicationSocket, %{"app_key" => app.credential.app_key}, %{:uri => %URI{host: "localhost"}})
  end
end