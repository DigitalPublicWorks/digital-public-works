defmodule DigitalPublicWorksWeb.OrganizationProjectController do
  use DigitalPublicWorksWeb, :controller

  alias DigitalPublicWorks.Organizations

  plug DigitalPublicWorksWeb.Plugs.GetOrganization
  plug DigitalPublicWorksWeb.Plugs.GetProject, "project_id"

  def create(%{assigns: %{organization: organization, project: project}} = conn, _params) do
    Organizations.add_project(organization, project)

    conn
    |> put_flash(:info, "Project added to organization.")
    |> redirect(to: Routes.organization_path(conn, :show, organization))
  end

  def delete(%{assigns: %{organization: organization, project: project}} = conn, _params) do
    Organizations.remove_project(organization, project)

    conn
    |> put_flash(:info, "Project removed from organization.")
    |> redirect(to: Routes.organization_path(conn, :show, organization))
  end
end
