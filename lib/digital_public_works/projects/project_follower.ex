defmodule DigitalPublicWorks.Projects.ProjectFollower do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.{Accounts.User, Projects.Project}

  @primary_key false
  @foreign_key_type :binary_id

  schema "projects_followers" do
    belongs_to :project, Project
    belongs_to :user, User

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :project_id])
    |> validate_required([:user_id, :project_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:project_id)
  end
end
