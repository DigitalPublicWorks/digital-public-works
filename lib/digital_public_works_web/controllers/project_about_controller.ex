defmodule DigitalPublicWorksWeb.ProjectAboutController do
  use DigitalPublicWorksWeb, :controller
  alias DigitalPublicWorks.Projects

  plug DigitalPublicWorksWeb.Plugs.GetProject
  plug DigitalPublicWorksWeb.Plugs.Authorize, :project

  def edit(conn, _params) do
    project = conn.assigns.project

    conn
    |> assign(:project, project)
    |> assign(:changeset, Projects.change_project(project))
    |> assign(:action, Routes.project_about_path(conn, :update, project))
    |> render("edit.html")
  end

  def update(conn, %{"project" => project_params}) do
    project = conn.assigns.project

    Projects.update_project(project, project_params)

    conn
    |> put_flash(:info, "Project updated successfully.")
    |> redirect(to: Routes.project_path(conn, :show, project))
  end

end
