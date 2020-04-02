defmodule DigitalPublicWorksWeb.ProjectView do
  use DigitalPublicWorksWeb, :view

  alias DigitalPublicWorks.Projects.Project
  alias DigitalPublicWorks.Repo

  def new_post(%Project{} = project) do
    Ecto.build_assoc(project, :posts)
    |> Repo.preload(:project)
  end

  def organization_links(conn, %{organizations: organizations}) do
    organizations
    |> Enum.map(fn o ->
      link(o.name, to: Routes.organization_path(conn, :show, o), class: "text-body font-weight-bold")
    end)
  end
end
