defmodule DigitalPublicWorks.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.Projects.Project

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "post" do
    field :body, :string
    belongs_to :project, Project

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
