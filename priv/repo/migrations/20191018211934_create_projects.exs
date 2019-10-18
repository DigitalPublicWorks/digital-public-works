defmodule DigitalPublicWorks.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :body, :text

      timestamps()
    end

    create unique_index(:projects, [:title])
  end
end
