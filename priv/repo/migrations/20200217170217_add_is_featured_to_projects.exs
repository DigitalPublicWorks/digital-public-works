defmodule DigitalPublicWorks.Repo.Migrations.AddIsFeaturedToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :is_featured, :boolean, default: :false
    end
  end
end
