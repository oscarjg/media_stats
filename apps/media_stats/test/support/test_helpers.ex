defmodule MediaStats.Support.TestHelpers do
  @moduledoc """
  Helper module to create some fixtures
  """
  alias MediaStats.Accounts

  def user_fixture(attr \\ %{}) do
    user_name = "user#{System.unique_integer([:positive])}"

    attr =
      attr
      |> Enum.into(%{
        name: user_name,
        credential: %{
          email: attr[:email] || "#{user_name}@foo.com",
          password: attr[:password] || "super_secret"
        }
      })

    Accounts.create_registered_user(attr)
  end

  def application_fixture(user, attr \\ %{}) do
    app_name = "application#{System.unique_integer([:positive])}"

    attr =
      attr
      |> Enum.into(%{
        name: app_name,
        credential: %{
          app_key: attr[:app_key] || "foo-api-key-" <> app_name,
          allowed_hosts: attr[:allowed_hosts] || "127.0.0.1"
        }
      })

    Accounts.create_application(user, attr)
  end
end
