defmodule DigitalPublicWorks.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias DigitalPublicWorks.Projects.Project
  alias DigitalPublicWorks.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "posts" do
    field :title, :string
    field :body, :string
    belongs_to :project, Project
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :project_id, :user_id])
    |> validate_required([:title, :body, :project_id, :user_id])
    |> sanitize_body
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:user_id)
  end

  defp sanitize_body(%Ecto.Changeset{changes: %{body: body}} = changeset) do
    changeset
    |> change(%{body: HtmlSanitizeEx.markdown_html(body)})
  end
  defp sanitize_body(changeset), do: changeset
end
