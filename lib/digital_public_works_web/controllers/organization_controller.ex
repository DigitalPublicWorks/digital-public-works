defmodule DigitalPublicWorksWeb.OrganizationController do
  use DigitalPublicWorksWeb, :controller

  alias DigitalPublicWorks.{Organizations, Repo}

  plug DigitalPublicWorksWeb.Plugs.GetOrganization
  plug DigitalPublicWorksWeb.Plugs.GetProject, "project_id" when action in [:add_project, :remove_project]
  plug DigitalPublicWorksWeb.Plugs.Authorize, :organization

  def show(%{assigns: %{organization: organization}} = conn, _params) do
    conn
    |> assign(:organization, organization |> Repo.preload(projects: :user))
    |> render("show.html")
  end

  def add_project(%{assigns: %{organization: organization, project: project}} = conn, _params) do
    Organizations.add_project(organization, project)

    conn
    |> put_flash(:info, "Project added to organization.")
    |> redirect(to: Routes.organization_path(conn, :show, organization))
  end

  def remove_project(%{assigns: %{organization: organization, project: project}} = conn, _params) do
    Organizations.remove_project(organization, project)

    conn
    |> put_flash(:info, "Project removed from organization.")
    |> redirect(to: Routes.organization_path(conn, :show, organization))
  end
end
