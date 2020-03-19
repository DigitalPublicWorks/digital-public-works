defmodule DigitalPublicWorks.Invites do

  import Ecto.Query, warn: false
  alias DigitalPublicWorks.Repo

  alias DigitalPublicWorks.Invites.ProjectInvite
  alias DigitalPublicWorks.Projects
  alias DigitalPublicWorks.Projects.Project

  @doc """
  Returns the list of project_invites.

  ## Examples

      iex> list_project_invites()
      [%ProjectInvite{}, ...]

  """
  def list_project_invites do
    Repo.all(ProjectInvite)
  end

  @doc """
  Gets a single project_invite.

  Raises `Ecto.NoResultsError` if the Project invite does not exist.

  ## Examples

      iex> get_project_invite!(123)
      %ProjectInvite{}

      iex> get_project_invite!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project_invite!(id), do: Repo.get!(ProjectInvite, id)

  @doc """
  Creates a project_invite.

  ## Examples

      iex> create_project_invite(%{field: value})
      {:ok, %ProjectInvite{}}

      iex> create_project_invite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_invite(%Project{} = project, attrs \\ %{}) do
    %ProjectInvite{}
    |> ProjectInvite.changeset(attrs)
    |> Ecto.Changeset.put_change(:project_id, project.id)
    |> Repo.insert()
  end

  @doc """
  Updates a project_invite.

  ## Examples

      iex> update_project_invite(project_invite, %{field: new_value})
      {:ok, %ProjectInvite{}}

      iex> update_project_invite(project_invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project_invite(%ProjectInvite{} = project_invite, user) do
    with {:ok, _} <- Projects.add_user(project_invite.project, user),
         do: delete_project_invite(project_invite)
  end

  @doc """
  Deletes a ProjectInvite.

  ## Examples

      iex> delete_project_invite(project_invite)
      {:ok, %ProjectInvite{}}

      iex> delete_project_invite(project_invite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project_invite(%ProjectInvite{} = project_invite) do
    Repo.delete(project_invite)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project_invite changes.

  ## Examples

      iex> change_project_invite(project_invite)
      %Ecto.Changeset{source: %ProjectInvite{}}

  """
  def change_project_invite(%ProjectInvite{} = project_invite \\ %ProjectInvite{}) do
    ProjectInvite.changeset(project_invite, %{})
  end

end
