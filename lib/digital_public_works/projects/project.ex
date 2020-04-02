defmodule DigitalPublicWorks.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.Accounts.User
  alias DigitalPublicWorks.Invites.ProjectInvite
  alias DigitalPublicWorks.Projects.{ProjectFollower, ProjectUser, ProjectSlug}
  alias DigitalPublicWorks.Posts.Post
  alias DigitalPublicWorks.Organizations.{Organization, OrganizationProject}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "projects" do
    field :body, :string
    field :title, :string
    field :about, :string
    field :is_featured, :boolean
    field :is_public, :boolean, default: :false
    field :slug, :string
    belongs_to :user, User
    has_many :posts, Post
    many_to_many :followers, User, join_through: ProjectFollower
    many_to_many :users, User, join_through: ProjectUser
    has_many :project_invites, ProjectInvite
    has_many :project_slugs, ProjectSlug, on_replace: :delete
    many_to_many :organizations, Organization, join_through: OrganizationProject

    timestamps()
  end

  @doc false
  def changeset(project, attrs \\ %{}) do
    project
    |> cast(attrs, [:title, :body, :about])
    |> validate_required([:title, :body])
    |> unique_constraint(:title)
    |> sanitize_about()
    |> generate_slug()
    |> foreign_key_constraint(:followers,
      name: "projects_followers_project_id_fkey",
      message: "You can't delete a project that has followers."
    )
    |> unique_constraint(:title,
      name: "projects_slug_index",
      message: "has already been taken"
    )
    |> unique_constraint(:title,
      name: "project_slugs_pkey",
      message: "has already been taken"
    )
  end

  defp sanitize_about(%Ecto.Changeset{changes: %{about: about}} = changeset) do
    changeset
    |> change(%{about: HtmlSanitizeEx.markdown_html(about)})
  end
  defp sanitize_about(changeset), do: changeset

  defp generate_slug(changeset) do
    slug =
      (changeset.changes[:title] || changeset.data.title || "")
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9\s-]/, "")
      |> String.replace(~r/(\s|-)+/, "-")

    changeset
    |> change(%{slug: slug})
  end
end

defimpl Phoenix.Param, for: DigitalPublicWorks.Projects.Project do
  def to_param(%{slug: slug}), do: slug
end
