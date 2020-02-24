defmodule DigitalPublicWorks.Repo.Migrations.RecreatePosts do
  use Ecto.Migration

  def change do
    rename table(:post), to: table(:posts)

    alter table(:posts) do
      add :user_id, references(:users, type: :uuid), null: false
      add :title, :string
    end

    create index(:posts, [:project_id])
  end
end
