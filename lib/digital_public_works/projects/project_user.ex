defmodule DigitalPublicWorks.Projects.ProjectUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.{Accounts.User, Projects.Project}

  @primary_key false
  @foreign_key_type :binary_id

  schema "projects_users" do
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
    |> unique_constraint(:user_id, name: "projects_users_project_id_user_id_index", message: "You already joined this project")
  end
end
