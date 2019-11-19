defmodule DigitalPublicWorksWeb.ProjectView do
  use DigitalPublicWorksWeb, :view

  alias DigitalPublicWorks.Projects.Project
  alias DigitalPublicWorks.Repo

  def new_post(%Project{} = project) do
    Ecto.build_assoc(project, :posts)
    |> Repo.preload(:project)
  end
end
