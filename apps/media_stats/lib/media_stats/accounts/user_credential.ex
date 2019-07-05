defmodule MediaStats.Accounts.UserCredential do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_credentials" do
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)

    belongs_to(:user, MediaStats.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 6, max: 100)
    |> unique_constraint(:email)
    |> put_pass_hash()
    |> validate_email()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Pbkdf2.hashpwsalt(pass))

      _ ->
        changeset
    end
  end

  defp validate_email(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{email: email}} ->
        case Regex.match?(~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/, email) do
          true ->
            changeset

          false ->
            add_error(changeset, :email, "invalid email format")
        end

      _ ->
        changeset
    end
  end
end
