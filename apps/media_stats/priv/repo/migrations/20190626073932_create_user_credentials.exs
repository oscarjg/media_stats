defmodule MediaStats.Repo.Migrations.CreateUserCredentials do
  use Ecto.Migration

  def change do
    create table(:user_credentials) do
      add :email, :string
      add :password_hash, :string
      add :user_id, references(:users, on_delete: :delete_all), [null: false]

      timestamps()
    end

    create unique_index(:user_credentials, [:email])
    create index(:user_credentials, [:user_id])
  end
end
