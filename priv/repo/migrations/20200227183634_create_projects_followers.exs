defmodule DigitalPublicWorks.Repo.Migrations.CreateProjectsFollowers do
  use Ecto.Migration

  def change do
    create table(:projects_followers, primary_key: false) do
      add :project_id, references(:projects, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:projects_followers, [:project_id, :user_id])
  end
end
