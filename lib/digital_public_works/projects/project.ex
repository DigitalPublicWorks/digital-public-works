defmodule DigitalPublicWorks.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "projects" do
    field :body, :string
    field :title, :string
    belongs_to :user, User

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
