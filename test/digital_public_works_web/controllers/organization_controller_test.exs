defmodule DigitalPublicWorksWeb.OrganizationControllerTest do
  use DigitalPublicWorksWeb.ConnCase

  alias DigitalPublicWorks.Organizations

  defp create_organization(_) do
    {:ok, organization: insert(:organization)}
  end

  defp create_project(_) do
    {:ok, project: insert(:project)}
  end

  defp create_organization_project(%{organization: organization}) do
    project = insert(:project)
    Organizations.add_project(organization, project)
    {:ok, organization_project: project}
  end

  defp assert_no_access(conn) do
    assert redirected_to(conn) == Routes.page_path(conn, :index)
    assert get_flash(conn, :error) =~ "You don't have access to that"
  end

  defp assert_needs_login(conn) do
    assert redirected_to(conn) == Routes.session_path(conn, :new)
    assert get_flash(conn, :info) =~ "You need to log in first"
  end

  describe "show organization" do
    setup [:create_organization, :create_organization_project]

    test "displays name", %{conn: conn, organization: organization} do
      conn = get(conn, Routes.organization_path(conn, :show, organization))

      assert html_response(conn, 200) =~ organization.name
    end

    @tag :as_user
    test "shows unpublished projects to org members", %{conn: conn, user: user, organization: organization, organization_project: organization_project} do
      Organizations.add_user(organization, user)

      conn = get(conn, Routes.organization_path(conn, :show, organization))

      assert html_response(conn, 200) =~ organization_project.title
      assert html_response(conn, 200) =~ "Unpublished"
    end

    test "doesn't show unpublished projects to non-org members", %{conn: conn, organization: organization, organization_project: organization_project} do
      conn = get(conn, Routes.organization_path(conn, :show, organization))

      refute html_response(conn, 200) =~ organization_project.title
      refute html_response(conn, 200) =~ "Unpublished"
    end
  end

  describe "add projects" do
    setup [:create_organization, :create_project]

    @tag :as_user
    test "organization member can add project", %{conn: conn, user: user, organization: organization, project: project} do
      Organizations.add_user(organization, user)

      conn = post(conn, Routes.organization_path(conn, :add_project, organization, %{project_id: project.id}))

      assert redirected_to(conn) == Routes.organization_path(conn, :show, organization)
      assert get_flash(conn, :info) =~ "Project added to organization"
    end

    @tag :as_user
    test "non organization member can't add project", %{conn: conn, organization: organization, project: project} do
      conn = post(conn, Routes.organization_path(conn, :add_project, organization, %{project_id: project.id}))

      assert_no_access conn
    end

    test "anonymous user can't add project", %{conn: conn, organization: organization, project: project} do
      conn = post(conn, Routes.organization_path(conn, :add_project, organization, %{project_id: project.id}))

      assert_needs_login conn
    end
  end

  describe "remove projects" do
    setup [:create_organization, :create_organization_project]

    @tag :as_user
    test "organization member can remove project", %{conn: conn, user: user, organization: organization, organization_project: project} do
      Organizations.add_user(organization, user)

      conn = delete(conn, Routes.organization_path(conn, :remove_project, organization, %{project_id: project.id}))

      assert redirected_to(conn) == Routes.organization_path(conn, :show, organization)
      assert get_flash(conn, :info) =~ "Project removed from organization"
    end

    @tag :as_user
    test "non organization members can't remove project", %{conn: conn, organization: organization, organization_project: project} do
      conn = delete(conn, Routes.organization_path(conn, :remove_project, organization, %{project_id: project.id}))

      assert_no_access conn
    end

    test "anonymous users can't remove project", %{conn: conn, organization: organization, organization_project: project} do
      conn = delete(conn, Routes.organization_path(conn, :remove_project, organization, %{project_id: project.id}))

      assert_needs_login conn
    end
  end
end
