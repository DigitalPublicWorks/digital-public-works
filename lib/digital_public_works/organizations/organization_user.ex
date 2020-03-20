defmodule DigitalPublicWorks.Organizations.OrganizationUser do
  use Ecto.Schema

  alias DigitalPublicWorks.{Organizations.Organization, Accounts.User}

  @primary_key false
  @foreign_key_type :binary_id

  schema "organizations_users" do
    belongs_to :organization, Organization
    belongs_to :user, User

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:organization_id, :user_id])
    |> Ecto.Changeset.validate_required([:organization_id, :user_id])
    |> Ecto.Changeset.foreign_key_constraint(:organization_id)
    |> Ecto.Changeset.foreign_key_constraint(:user_id)
    |> Ecto.Changeset.unique_constraint(:user_id, name: "organizations_users_organization_id_user_id_index", message: "You already joined this project")
  end
end
