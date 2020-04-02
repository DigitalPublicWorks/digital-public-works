defmodule DigitalPublicWorks.Organizations.OrganizationUser do
  use Ecto.Schema
  import Ecto.Changeset

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
    |> cast(params, [:organization_id, :user_id])
    |> validate_required([:organization_id, :user_id])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id, name: "organizations_users_organization_id_user_id_index", message: "You already joined this project")
  end
end
