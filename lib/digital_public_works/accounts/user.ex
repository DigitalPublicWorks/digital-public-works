defmodule DigitalPublicWorks.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.Projects.{Project, ProjectFollower, ProjectUser}
  alias DigitalPublicWorks.Organizations.{Organization, OrganizationUser}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :display_name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :is_admin, :boolean, default: :false
    has_many :projects, Project
    many_to_many :followed_projects, Project, join_through: ProjectFollower
    many_to_many :joined_projects, Project, join_through: ProjectUser
    many_to_many :organizations, Organization, join_through: OrganizationUser

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> common_changeset(attrs)
    |> put_pass_hash
  end

  def create_changeset(%__MODULE__{} = user, attrs) do
    user
    |> common_changeset(attrs)
    |> validate_required([:password])
    |> put_pass_hash
  end

  defp common_changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:display_name, :email, :password])
    |> validate_required([:email])
    |> unique_constraint(:email)
    |> validate_length(:password, min: 8)
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset
end

defimpl Bamboo.Formatter, for: DigitalPublicWorks.Accounts.User do
  def format_email_address(user, _opts) do
    {"", user.email}
  end
end
