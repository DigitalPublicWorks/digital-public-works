defmodule DigitalPublicWorks.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias DigitalPublicWorks.Repo

  alias DigitalPublicWorks.Projects.{Project, ProjectFollower, ProjectUser}
  alias DigitalPublicWorks.Accounts.User

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects(), do: all() |> fetch()

  def list_published_projects(search \\ nil), do: all() |> published() |> fetch(search)

  def list_featured_projects(), do: all() |> featured() |> fetch()

  def list_endorsed_projects(search \\ nil), do: all() |> endorsed() |> fetch(search)

  def list_followed_projects(%User{} = user), do: all() |> followed_by(user) |> fetch()
  def list_followed_projects(_), do: []

  def list_owned_projects(%User{} = user), do: all() |> owned_by(user) |> fetch()
  def list_owned_projects(_), do: []

  def list_joined_projects(%User{} = user), do: all() |> joined_by(user) |> fetch()
  def list_joined_projects(_), do: []

  @doc """
    scopes

  """

  def all(), do: Project

  def published(query) do
    from(p in query, where: [is_public: true])
  end

  def featured(query) do
    from(p in query, where: [is_featured: true])
  end

  def endorsed(query) do
    from(p in query, inner_join: o in assoc(p, :organizations))
  end

  def joined_by(query, user) do
    from(p in query, inner_join: u in assoc(p, :users), where: u.id == ^user.id)
  end

  def owned_by(query, user) do
    from(p in query, inner_join: u in assoc(p, :user), where: u.id == ^user.id)
  end

  def followed_by(query, user) do
    from(p in query, inner_join: u in assoc(p, :followers), where: u.id == ^user.id)
  end

  def for_organization(query, organization) do
    from(p in query, inner_join: o in assoc(p, :organizations), where: o.id == ^organization.id)
  end
  def preload(query, associations \\ [:user, :organizations]) do
    query |> Repo.preload(associations)
  end

  def fetch(query, search \\ nil) do
    from(p in query) |> filter_projects(search) |> Repo.all() |> preload()
  end

  defp filter_projects(query, ""), do: filter_projects(query, nil)

  defp filter_projects(query, nil) do
    from p in query,
      order_by: [desc: :is_featured],
      order_by: [desc: :inserted_at]
  end

  defp filter_projects(query, search) do
    from p in query,
      where: fragment("to_tsvector(title || ' ' || body) @@ plainto_tsquery(?)", ^search),
      order_by:
        fragment("ts_rank(to_tsvector(title || ' ' || body), plainto_tsquery(?)) DESC", ^search)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id) |> preload()

  def get_project_by_slug!(slug) do
    from(p in Project, inner_join: s in assoc(p, :project_slugs), where: s.slug == ^slug)
    |> Repo.one!() |> preload()
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(%User{} = user, attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    project
    |> Project.changeset()
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{source: %Project{}}

  """
  def change_project(%Project{} = project) do
    Project.changeset(project, %{})
  end

  def publish_project(%Project{} = project) do
    project
    |> Ecto.Changeset.change(%{is_public: true})
    |> Repo.update()
  end

  def unpublish_project(%Project{} = project) do
    project
    |> Ecto.Changeset.change(%{is_public: false})
    |> Repo.update()
  end

  def add_follower(%Project{} = project, %User{} = user) do
    %ProjectFollower{}
    |> ProjectFollower.changeset(%{user_id: user.id, project_id: project.id})
    |> Repo.insert()
  end

  def remove_follower(%Project{} = project, %User{} = user) do
    from(p in ProjectFollower, where: p.user_id == ^user.id and p.project_id == ^project.id)
    |> Repo.delete_all()
  end

  def is_follower?(%Project{} = project, %User{} = user) do
    from(p in ProjectFollower, where: p.user_id == ^user.id and p.project_id == ^project.id)
    |> Repo.exists?()
  end

  def is_follower?(_, _), do: false

  def add_user(%Project{} = project, %User{} = user) do
    %ProjectUser{}
    |> ProjectUser.changeset(%{user_id: user.id, project_id: project.id})
    |> Repo.insert()
  end

  def remove_user(%Project{} = project, %User{} = user) do
    from(p in ProjectUser, where: p.user_id == ^user.id and p.project_id == ^project.id)
    |> Repo.delete_all()
  end

  def is_user?(%Project{} = project, %User{} = user) do
    from(p in ProjectUser, where: p.user_id == ^user.id and p.project_id == ^project.id)
    |> Repo.exists?()
  end

  def is_user?(_, _), do: false
end
