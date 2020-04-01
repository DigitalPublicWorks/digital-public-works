defmodule DigitalPublicWorks.Projects.ProjectSlug do
  use Ecto.Schema

  @primary_key {:slug, :string, []}
  @foreign_key_type :string

  schema "project_slugs" do
    field :project_id, :binary_id
    timestamps()
  end
end
