defmodule DigitalPublicWorks.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.Accounts.User
  alias DigitalPublicWorks.Projects.ProjectFollower
  alias DigitalPublicWorks.Posts.Post

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "projects" do
    field :body, :string
    field :title, :string
    field :is_featured, :boolean
    field :is_public, :boolean, default: :false
    belongs_to :user, User
    has_many :posts, Post
    many_to_many :followers, User, join_through: ProjectFollower

    timestamps()
  end

  @doc false
  def changeset(project, attrs \\ %{}) do
    project
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> unique_constraint(:title)
    |> sanitize_body
    |> Ecto.Changeset.foreign_key_constraint(:followers,
      name: "projects_followers_project_id_fkey",
      message: "You can't delete a project that has followers."
    )
  end

  defp sanitize_body(%Ecto.Changeset{changes: %{body: body}} = changeset) do
    changeset
    |> change(%{body: HtmlSanitizeEx.markdown_html(body)})
  end
  defp sanitize_body(changeset), do: changeset
end
