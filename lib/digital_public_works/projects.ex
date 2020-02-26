defmodule DigitalPublicWorks.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias DigitalPublicWorks.Repo

  alias DigitalPublicWorks.Projects.Project
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
    |> Repo.all
  end

  def list_projects(%User{is_admin: true}, search) do
    Project
    |> filter_projects(search)
    |> Repo.all
  end

  def list_projects(%User{id: user_id}, search) do
    (from p in Project, where: p.is_public == true or p.user_id == ^user_id)
    |> filter_projects(search)
    |> Repo.all
  end

  defp filter_projects(query, []), do: query

  defp filter_projects(query, search) do
    from p in query, where: ilike(p.title, ^"%#{search}%")
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

    Repo.all(query)
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
  def get_project!(id), do: Repo.get!(Project, id)

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
    Repo.delete(project)
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
    |> Repo.update
  end

  def unpublish_project(%Project{} = project) do
    project
    |> Ecto.Changeset.change(%{is_public: false})
    |> Repo.update
  end
end
