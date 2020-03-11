defmodule DigitalPublicWorks.Accounts.ProjectInvite do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.Projects.Project

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_invites" do
    field :email, :string
    belongs_to :project, Project

    timestamps()
  end

  @doc false
  def changeset(project_invite, attrs) do
    project_invite
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end
end

defimpl Bamboo.Formatter, for: DigitalPublicWorks.Accounts.ProjectInvite do
  def format_email_address(user, _opts) do
    {"", user.email}
  end
end
