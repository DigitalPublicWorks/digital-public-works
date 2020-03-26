defmodule DigitalPublicWorksWeb.OrganizationControllerTest do
  use DigitalPublicWorksWeb.ConnCase

  alias DigitalPublicWorks.Organizations

  @tag :as_user
  test "organization member can add project", %{conn: conn, user: user} do
    project = insert(:project)
    organization = insert(:organization)

    Organizations.add_user(organization, user)

    conn = post(conn, Routes.organization_project_path(conn, :create, organization, %{project_id: project.id}))

    assert redirected_to(conn) == Routes.organization_path(conn, :show, organization)
    assert get_flash(conn, :info) =~ "Project added to organization"
  end

  @tag :as_user
  test "organization member can remove project", %{conn: conn, user: user} do
    project = insert(:project)
    organization = insert(:organization)

    Organizations.add_project(organization, project)
    Organizations.add_user(organization, user)

    conn = delete(conn, Routes.organization_project_path(conn, :delete, organization, %{project_id: project.id}))

    assert redirected_to(conn) == Routes.organization_path(conn, :show, organization)
    assert get_flash(conn, :info) =~ "Project removed from organization"
  end
end
