defmodule DigitalPublicWorks.Repo.Migrations.RecreatePosts do
  use Ecto.Migration

  def change do
    drop table(:post)

    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :body, :text
      add :project_id, references(:projects, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid), null: false

      timestamps()
    end

    create index(:posts, [:project_id])
    create index(:posts, [:user_id])
  end
end
