defmodule DigitalPublicWorks.Repo.Migrations.CreateProjectSlugs do
  use Ecto.Migration
  import Ecto.Query

  alias DigitalPublicWorks.{Projects.Project, Repo}

  def up do
    create table(:project_slugs, primary_key: false) do
      add :slug, :string, primary_key: true
      add :project_id, references(:projects, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :naive_datetime_usec)
    end

    create index(:project_slugs, [:project_id])

    alter table(:projects) do
      add :slug, :string
    end

    execute """
    CREATE FUNCTION create_project_slug() RETURNS trigger AS $create_project_slug$
      BEGIN
        UPDATE project_slugs SET updated_at = clock_timestamp() WHERE project_id = NEW.ID AND slug = NEW.slug;

        IF FOUND THEN
          RETURN NEW;
        END IF;

        INSERT INTO "project_slugs" ("slug", "project_id", "inserted_at", "updated_at")
          VALUES (NEW.slug, NEW.id, clock_timestamp(), clock_timestamp());

        DELETE FROM "project_slugs"
          WHERE "slug" IN (
            SELECT "slug" FROM "project_slugs"
            WHERE "project_id" = NEW.id
            ORDER BY "updated_at" DESC
            OFFSET 10
          );

        RETURN NEW;
      END;
    $create_project_slug$ LANGUAGE plpgsql;
    """

    execute """
    CREATE TRIGGER create_project_slug AFTER INSERT OR UPDATE ON projects
      FOR EACH ROW EXECUTE PROCEDURE create_project_slug();
    """

    flush()

    for project <- from(p in Project) |> Repo.all() do
      project
      |> Project.changeset()
      |> Repo.update!()
    end

    alter table(:projects) do
      modify :slug, :string, null: false
    end

    create unique_index(:projects, :slug)
  end

  def down do
    alter table(:projects) do
      remove :slug
    end

    execute "DROP TRIGGER create_project_slug ON projects;"
    execute "DROP FUNCTION create_project_slug;"

    drop table(:project_slugs)
  end
end
