defmodule DigitalPublicWorks.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias DigitalPublicWorks.Repo

  alias DigitalPublicWorks.Organizations.Organization

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%Organization{}, ...]

  """
  def list_organizations do
    Repo.all(Organization)
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(id), do: Repo.get!(Organization, id)

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{source: %Organization{}}

  """
  def change_organization(%Organization{} = organization) do
    Organization.changeset(organization, %{})
  end

  def get_organization_by_slug(slug) do
    from(o in Organization, where: [slug: ^slug]) |> Repo.one()
  end

  alias DigitalPublicWorks.Accounts.User
  alias DigitalPublicWorks.Organizations.OrganizationUser

  def add_user(%Organization{} = organization, %User{} = user) do
    %OrganizationUser{}
    |> Ecto.Changeset.change(%{organization_id: organization.id, user_id: user.id})
    |> Repo.insert()
  end

  def remove_user(%Organization{} = organization, %User{} = user) do
    organization_user_query(organization, user) |> Repo.delete_all()
  end

  def is_user?(%Organization{} = organization, %User{} = user) do
    organization_user_query(organization, user) |> Repo.exists?()
  end

  def is_user?(_, nil), do: false

  defp organization_user_query(%Organization{} = organization, %User{} = user) do
    from(o in OrganizationUser,
      where: o.organization_id == ^organization.id and o.user_id == ^user.id
    )
  end

  alias DigitalPublicWorks.Projects.Project
  alias DigitalPublicWorks.Organizations.OrganizationProject

  def add_project(%Organization{} = organization, %Project{} = project) do
    %OrganizationProject{}
    |> Ecto.Changeset.change(%{organization_id: organization.id, project_id: project.id})
    |> Repo.insert()
  end

  def remove_project(%Organization{} = organization, %Project{} = project) do
    organization_project_query(organization, project) |> Repo.delete_all()
  end

  def is_project?(%Organization{} = organization, %Project{} = project) do
    organization_project_query(organization, project) |> Repo.exists?()
  end

  def is_project?(_, nil), do: false

  defp organization_project_query(%Organization{} = organization, %Project{} = project) do
    from(o in OrganizationProject,
      where: o.organization_id == ^organization.id and o.project_id == ^project.id
    )
  end
end
