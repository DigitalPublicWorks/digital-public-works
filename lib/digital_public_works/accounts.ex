defmodule DigitalPublicWorks.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias DigitalPublicWorks.Repo

  alias DigitalPublicWorks.Projects
  alias DigitalPublicWorks.Accounts.User
  alias DigitalPublicWorks.Projects.Project

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def get_user_by(%{"email" => email}) do
    User
    |> Repo.get_by(email: email)
  end

  def verify_user(%{"password" => password} = params) do
    params
    |> get_user_by()
    |> Argon2.check_pass(password)
  end

  alias DigitalPublicWorks.Accounts.ProjectInvite

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

  def find_or_create_by_email(email) do
    case get_user_by(%{"email" => email}) do
      nil ->
        length = 32
        password = :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)
        create_user(%{email: email, password: password})
      user -> {:ok, user}
    end
  end
end
