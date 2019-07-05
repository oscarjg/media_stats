defmodule MediaStats.Accounts.ApplicationTest do
  use MediaStats.Support.DataBaseCase

  alias MediaStats.Accounts.Application
  alias MediaStats.Repo

  test "valid changesets without database constraints" do
    assert %Ecto.Changeset{valid?: true} =
             Application.changeset(%Application{}, %{name: "Foo app", user_id: 1})
  end

  test "non valid changesets without database constraints" do
    assert %Ecto.Changeset{valid?: false} =
             Application.changeset(%Application{}, %{name: "", user_id: 1})

    assert %Ecto.Changeset{valid?: false} =
             Application.changeset(%Application{}, %{non_mapped: "Foo app"})
  end

  test "changeset with user database constraints" do
    {:ok, user} = user_fixture()

    assert changeset =
             %Ecto.Changeset{valid?: true} =
             Application.changeset(%Application{}, %{name: "Foo app", user_id: user.id})

    assert {:ok, _} = Repo.insert(changeset)

    Repo.delete(user)

    assert {:error, %Ecto.Changeset{valid?: false}} = Repo.insert(changeset)
  end

  test "validate registration changeset" do
    {:ok, user} = user_fixture()

    assert changeset = %Ecto.Changeset{valid?: true} =
             Application.registration_changeset(
               %Application{},
               %{
                 name: "Foo app",
                 user_id: user.id,
                 credential: %{
                   app_key: "foo-api-key",
                   allowed_hosts: ""
                 }
               }
             )

    assert {:ok, _} = Repo.insert(changeset)

    assert changeset = %Ecto.Changeset{valid?: true} =
             Application.registration_changeset(
               %Application{},
               %{
                 name: "Bar app",
                 user_id: user.id,
                 credential: %{
                   app_key: "foo-api-key",
                   allowed_hosts: ""
                 }
               }
             )

    assert {:error, %Ecto.Changeset{valid?: false}} = Repo.insert(changeset)

    assert %Ecto.Changeset{valid?: false} =
             Application.registration_changeset(
               %Application{},
               %{
                 name: "Foo app",
                 user_id: user.id,
                 credential: %{
                   app_key: "",
                   allowed_hosts: ""
                 }
               }
             )

    assert %Ecto.Changeset{valid?: false} =
             Application.registration_changeset(
               %Application{},
               %{
                 name: "Foo app",
                 user_id: user.id
               }
             )
  end
end
