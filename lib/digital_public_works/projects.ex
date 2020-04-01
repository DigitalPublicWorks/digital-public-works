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
  def list_projects(_user \\ nil, _search \\ nil)

  def list_projects(nil, search) do
    Project
    |> where(is_public: true)
    |> filter_projects(search)
    |> Repo.all()
  end

  def list_projects(%User{is_admin: true}, search) do
    Project
    |> filter_projects(search)
    |> Repo.all()
  end

  def list_projects(%User{id: user_id}, search) do
    from(p in Project,
      left_join: u in assoc(p, :users),
      where: p.is_public == true or p.user_id == ^user_id or u.id == ^user_id
    )
    |> filter_projects(search)
    |> Repo.all()
  end

  def list_followed_projects(%User{} = user) do
    user
    |> Ecto.assoc(:followed_projects)
    |> filter_projects()
    |> Repo.all()
  end

  def list_followed_projects(_), do: []

  def list_owned_projects(%User{} = user) do
    user
    |> Ecto.assoc(:projects)
    |> filter_projects()
    |> Repo.all()
  end

  def list_owned_projects(_), do: []

  def list_joined_projects(%User{} = user) do
    user
    |> Ecto.assoc(:joined_projects)
    |> Repo.all()
  end

  def list_joined_projects(_), do: []

  defp filter_projects(query, search \\ nil)

  defp filter_projects(query, ""), do: filter_projects(query, nil)

  defp filter_projects(query, nil) do
    from p in query,
      order_by: [desc: :is_featured],
      order_by: [desc: :inserted_at],
      preload: [:user]
  end

  defp filter_projects(query, search) do
    from p in query,
      where: fragment("to_tsvector(title || ' ' || body) @@ plainto_tsquery(?)", ^search),
      order_by:
        fragment("ts_rank(to_tsvector(title || ' ' || body), plainto_tsquery(?)) DESC", ^search)
  end

  @doc """
  Returns the list of featured projects

  ## Examples

      iex> list_featured_projects()
      [%Project{}, ...]

  """
  def list_featured_projects do
    query =
      from p in Project,
        where: [is_featured: true]

    query
    |> filter_projects()
    |> Repo.all()
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
  def get_project!(id), do: Repo.get!(Project, id) |> Repo.preload([:user])

  def get_project_by_slug!(slug) do
    from(p in Project, inner_join: s in assoc(p, :project_slugs), where: s.slug == ^slug)
    |> Repo.one!() |> Repo.preload([:user])
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
