defmodule DigitalPublicWorks.Projects.ProjectUser do
  use Ecto.Schema

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
    |> Ecto.Changeset.cast(params, [:user_id, :project_id])
    |> Ecto.Changeset.validate_required([:user_id, :project_id])
    |> Ecto.Changeset.foreign_key_constraint(:user_id)
    |> Ecto.Changeset.foreign_key_constraint(:project_id)
    |> Ecto.Changeset.unique_constraint(:user_id, name: "projects_users_project_id_user_id_index", message: "You already joined this project")
  end
end
