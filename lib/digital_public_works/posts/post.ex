defmodule DigitalPublicWorks.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.Projects.Project
  alias DigitalPublicWorks.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "posts" do
    field :title, :string
    field :body, :string
    belongs_to :project, Project
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end
