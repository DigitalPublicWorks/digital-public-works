defmodule DigitalPublicWorks.Repo.Migrations.AddAboutToProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :about, :text
    end
  end
end
