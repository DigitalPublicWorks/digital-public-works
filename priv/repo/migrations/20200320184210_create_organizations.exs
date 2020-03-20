defmodule DigitalPublicWorks.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :slug, :string
      add :description, :string

      timestamps()
    end

    create unique_index(:organizations, :slug)

    create table(:organizations_users, primary_key: false) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:organizations_users, [:organization_id, :user_id])

    create table(:organizations_projects, primary_key: false) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :project_id, references(:projects, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:organizations_projects, [:organization_id, :project_id])
  end
end
