defmodule DigitalPublicWorks.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.{Accounts.User, Projects.Project}
  alias DigitalPublicWorks.Organizations.{OrganizationUser, OrganizationProject}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :description, :string
    field :name, :string
    field :slug, :string

    many_to_many :users, User, join_through: OrganizationUser
    many_to_many :projects, Project, join_through: OrganizationProject

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name, :slug, :description])
  end
end
