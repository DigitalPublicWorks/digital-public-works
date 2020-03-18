defmodule DigitalPublicWorks.Repo.Migrations.AddPasswordResetToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :reset_token, :string
      add :reset_sent_at, :naive_datetime
    end

    create unique_index(:users, [:reset_token])
  end
end
