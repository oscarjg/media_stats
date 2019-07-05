defmodule MediaStats.Accounts.Application do
  use Ecto.Schema
  import Ecto.Changeset

  alias MediaStats.Accounts.{User, ApplicationCredential}

  schema "applications" do
    field(:name, :string)

    belongs_to(:user, User)
    has_one(:credential, ApplicationCredential)

    timestamps()
  end

  def changeset(application, attrs \\ %{}) do
    application
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name])
    |> assoc_constraint(:user)
  end

  def registration_changeset(application, attrs \\ %{}) do
    changeset(application, attrs)
    |> cast_assoc(:credential, with: &ApplicationCredential.registration_changeset/2, required: true)
  end

  def updated_changeset(application, attrs \\ %{}) do
    changeset(application, attrs)
    |> cast_assoc(:credential, with: &ApplicationCredential.changeset/2, required: true)
  end
end
