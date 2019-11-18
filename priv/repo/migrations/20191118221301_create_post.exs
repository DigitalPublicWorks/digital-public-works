defmodule DigitalPublicWorks.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:post, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :text
      add :project_id, references(:projects, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:post, [:project_id])
  end
end
