defmodule DigitalPublicWorks.Projects.ProjectSlug do
  use Ecto.Schema

  # Maintained by DB trigger
  # priv/repo/migrations/20200331192041_create_project_slugs.exs

  @primary_key {:slug, :string, []}
  @foreign_key_type :string

  schema "project_slugs" do
    field :project_id, :binary_id
    timestamps()
  end
end
