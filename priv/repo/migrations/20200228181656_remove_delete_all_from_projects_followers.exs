defmodule DigitalPublicWorks.Repo.Migrations.RemoveDeleteAllFromProjectsFollowers do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE projects_followers DROP CONSTRAINT projects_followers_project_id_fkey"
    execute "ALTER TABLE projects_followers DROP CONSTRAINT projects_followers_user_id_fkey"
    alter table(:projects_followers) do
      modify :project_id, references(:projects, type: :uuid, on_delete: :restrict), null: false
      modify :user_id, references(:users, type: :uuid, on_delete: :restrict), null: false
    end
  end

  def down do
    execute "ALTER TABLE projects_followers DROP CONSTRAINT projects_followers_project_id_fkey"
    execute "ALTER TABLE projects_followers DROP CONSTRAINT projects_followers_user_id_fkey"
    alter table(:projects_followers) do
      modify :project_id, references(:projects, type: :uuid, on_delete: :delete_all), null: false
      modify :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
    end
  end
end
