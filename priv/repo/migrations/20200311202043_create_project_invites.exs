defmodule DigitalPublicWorks.Repo.Migrations.CreateProjectInvites do
  use Ecto.Migration

  def change do
    create table(:project_invites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :project_id, references(:projects, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:project_invites, [:project_id])
  end
end
