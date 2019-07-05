defmodule MediaStats.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias MediaStats.Accounts.{
    UserCredential,
    Application
  }

  schema "users" do
    field(:name, :string)
    field(:is_active, :boolean, default: true)

    has_one(:credential, UserCredential)
    has_many(:applications, Application)

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :is_active])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast_assoc(:credential, with: &UserCredential.changeset/2, required: true)
  end
end
