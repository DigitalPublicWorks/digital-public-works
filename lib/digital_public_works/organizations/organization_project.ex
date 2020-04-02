defmodule DigitalPublicWorks.Organizations.OrganizationProject do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.{Organizations.Organization, Projects.Project}

  @primary_key false
  @foreign_key_type :binary_id

  schema "organizations_projects" do
    belongs_to :organization, Organization
    belongs_to :project, Project

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:organization_id, :project_id])
    |> validate_required([:organization_id, :project_id])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint(:user_id, name: "organizations_projects_organization_id_project_id_index", message: "This project is already part of this organization")
  end
end
