defmodule MediaStats.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :is_active, :boolean, nullable: false, default: false

      timestamps()
    end
  end
end
