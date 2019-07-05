defmodule MediaStatsWeb.Support.TestHelpers do
  alias MediaStats.Support.TestHelpers

  def user_fixture(attr \\ %{}) do
    TestHelpers.user_fixture(attr)
  end

  def application_fixture(user, attr \\ %{}) do
    TestHelpers.application_fixture(user, attr)
  end

  def default_user(attr \\ %{}) do
    {:ok, user} = user_fixture(attr)
    user
  end
end