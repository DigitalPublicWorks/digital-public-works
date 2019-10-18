defmodule DigitalPublicWorks.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "projects" do
    field :body, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> unique_constraint(:title)
  end
end
