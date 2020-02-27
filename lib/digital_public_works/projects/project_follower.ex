defmodule DigitalPublicWorks.Projects.ProjectFollower do
  use Ecto.Schema

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
    |> Ecto.Changeset.cast(params, [:user_id, :project_id])
    |> Ecto.Changeset.validate_required([:user_id, :project_id])
    |> Ecto.Changeset.foreign_key_constraint(:user_id)
    |> Ecto.Changeset.foreign_key_constraint(:project_id)
  end
end
