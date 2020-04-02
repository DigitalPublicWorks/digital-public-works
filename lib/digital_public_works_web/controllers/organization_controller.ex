defmodule DigitalPublicWorksWeb.OrganizationController do
  use DigitalPublicWorksWeb, :controller

  alias DigitalPublicWorks.{Organizations, Projects}

  plug DigitalPublicWorksWeb.Plugs.GetOrganization
  plug DigitalPublicWorksWeb.Plugs.GetProject, "project_id" when action in [:add_project, :remove_project]
  plug DigitalPublicWorksWeb.Plugs.Authorize, :organization

  def show(%{assigns: %{organization: organization}} = conn, _params) do
    import Projects, only: [all: 0, for_organization: 2, published: 1, fetch: 1]

    projects = all() |> for_organization(organization)

    projects =
      if Organizations.is_user?(organization, conn.assigns.current_user) do
        projects
      else
        projects |> published()
      end

    conn
    |> assign(:projects, projects |> fetch())
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
