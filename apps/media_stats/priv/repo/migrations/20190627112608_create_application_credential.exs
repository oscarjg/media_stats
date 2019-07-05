defmodule MediaStats.Repo.Migrations.CreateApplicationCredential do
  use Ecto.Migration

  def change do
    create table(:application_credentials) do
      add :app_key, :string
      add :allowed_hosts, :string

      add :application_id, references(:applications, on_delete: :delete_all)

      timestamps()
    end

    create index(:application_credentials, [:application_id])
    create unique_index(:application_credentials, [:app_key])
  end
end
