defmodule MediaStats.AccountsTest do
  use MediaStats.Support.DataBaseCase

  alias MediaStats.Accounts.{User, Application}

  describe "users context" do
    test "create_registered_user: create registered user successfully" do
      attrs = %{
        name: "Foo",
        credential: %{
          email: "foo@server.com",
          password: "123456"
        }
      }

      assert {:ok, user} = MediaStats.Accounts.create_registered_user(attrs)
      assert user.name == "Foo"
      assert user.is_active == true
    end

    test "create_registered_user: try to register user with wrong parameters should return an error" do
      attrs = %{
        name: "",
        credential: %{
          email: "",
          password: ""
        }
      }

      assert {:error, %Ecto.Changeset{}} = MediaStats.Accounts.create_registered_user(attrs)
    end

    test "get_user: get stored user should be find it" do
      {:ok, user} = user_fixture(%{name: "test user"})

      user = MediaStats.Accounts.get_user(user.id)

      assert user.name == "test user"
    end

    test "get_user_by_email_credential: stored user should be retrieved" do
      user_fixture(%{credential: %{email: "foo@server.com", password: "123456"}})

      assert %User{} = MediaStats.Accounts.get_user_by_email_credential("foo@server.com")
    end

    test "get_user_by_email_credential: non stored user should be return nil" do
      refute nil = MediaStats.Accounts.get_user_by_email_credential("foo@server.com")
    end

    test "authenticate_user_by_email_and_password: should return ok or error" do
      user_fixture(%{credential: %{email: "foo@server.com", password: "123456"}})

      user_fixture(%{
        is_active: false,
        credential: %{email: "inactive@server.com", password: "123456"}
      })

      assert {:error, :not_found} =
               MediaStats.Accounts.authenticate_user_by_email_and_password(
                 "bar@server.com",
                 "123456"
               )

      assert {:error, :not_found} =
               MediaStats.Accounts.authenticate_user_by_email_and_password("", "123456")

      assert {:error, :not_found} =
               MediaStats.Accounts.authenticate_user_by_email_and_password("", "")

      assert {:error, :unauthorized} =
               MediaStats.Accounts.authenticate_user_by_email_and_password(
                 "inactive@server.com",
                 "123456"
               )

      assert {:error, :unauthorized} =
               MediaStats.Accounts.authenticate_user_by_email_and_password(
                 "foo@server.com",
                 "invalid-pass"
               )

      assert {:ok, %User{}} =
               MediaStats.Accounts.authenticate_user_by_email_and_password(
                 "foo@server.com",
                 "123456"
               )
    end
  end

  describe "accounts context" do
    test "create application should return ok or error" do
      {:ok, user} = user_fixture()

      assert {:ok, app} =
               MediaStats.Accounts.create_application(user, %{
                 name: "My new app",
                 credential: %{app_key: "foo-key", allowed_hosts: ""}
               })

      assert app.name == "My new app"
      assert app.user_id == user.id
      assert {:error, _} = MediaStats.Accounts.create_application(user, %{name: ""})
    end

    test "list applications should return only whose users are owner" do
      {:ok, user_1} = user_fixture()
      {:ok, user_2} = user_fixture()
      {:ok, user_3} = user_fixture()
      application_fixture(user_1)
      application_fixture(user_1)
      application_fixture(user_2)

      assert applications = MediaStats.Accounts.list_user_applications(user_1)
      assert Enum.count(applications) == 2
      assert applications = MediaStats.Accounts.list_user_applications(user_2)
      assert Enum.count(applications) == 1
      assert applications = MediaStats.Accounts.list_user_applications(user_3)
      assert Enum.count(applications) == 0
    end

    test "get application by user should return the application or nil" do
      {:ok, user_1} = user_fixture()
      {:ok, user_2} = user_fixture()
      {:ok, user_3} = user_fixture()
      {:ok, app_1} = application_fixture(user_1)
      {:ok, app_2} = application_fixture(user_2)

      assert %Application{} = MediaStats.Accounts.get_user_application!(user_1, app_1.id)
      assert %Application{} = MediaStats.Accounts.get_user_application!(user_2, app_2.id)
      assert_raise  Ecto.NoResultsError, fn -> MediaStats.Accounts.get_user_application!(user_2, app_1.id) end
      assert_raise  Ecto.NoResultsError, fn -> MediaStats.Accounts.get_user_application!(user_3, app_1.id) end
    end

    test "authenticate application should return ok or error" do
      {:ok, user} = user_fixture()
      {:ok, app_1} = application_fixture(user)

      {:ok, app_2} =
        application_fixture(user, %{
          credential: %{app_key: "foo-api-key", allowed_hosts: "127.0.0.1, 192.0.0.1"}
        })

      {:ok, app_3} =
        application_fixture(user, %{credential: %{app_key: "bar-api-key", allowed_hosts: ""}})

      assert {:ok, %Application{}} =
               MediaStats.Accounts.authenticate_application(app_1.credential.app_key, "127.0.0.1")

      assert {:error, :unauthorized} =
               MediaStats.Accounts.authenticate_application(app_1.credential.app_key, "")

      assert {:error, :unauthorized} =
               MediaStats.Accounts.authenticate_application(app_1.credential.app_key, "")

      assert {:error, :not_found} =
               MediaStats.Accounts.authenticate_application("not-api-key", "192.0.0.1")

      assert {:ok, %Application{}} =
               MediaStats.Accounts.authenticate_application(app_2.credential.app_key, "192.0.0.1")

      assert {:ok, %Application{}} =
               MediaStats.Accounts.authenticate_application(app_3.credential.app_key, "192.0.0.1")

      assert {:ok, %Application{}} =
               MediaStats.Accounts.authenticate_application(app_3.credential.app_key, "")
    end
  end
end
