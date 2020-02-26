defmodule DigitalPublicWorks.Repo.Migrations.AddIsAdminAndIsPublicFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_admin, :boolean, default: :false
    end
    alter table(:projects) do
      add :is_public, :boolean, default: :false
    end
  end
end
