defmodule DigitalPublicWorksWeb.ProjectInviteControllerTest do
  use DigitalPublicWorksWeb.ConnCase
  import Ecto.Query

  defp create_project(%{conn: conn}) do
    {:ok, project: insert(:project, user: conn.assigns.current_user)}
  end

  defp get_project_invite(project, email) do
    from(p in DigitalPublicWorks.Accounts.ProjectInvite, where: p.email == ^email)
    |> DigitalPublicWorks.Repo.one
    |> Map.put(:project, project)
  end

  @tag :as_user
  setup [:create_project]
  test "create invite", %{conn: conn, project: project} do
    email = "invite@example.com"

    conn = post(conn, Routes.project_invite_path(conn, :create, project), project_invite: %{email: email})

    assert redirected_to(conn) == Routes.project_invite_path(conn, :index, project)
    assert get_flash(conn, :info) =~ "Invite sent."

    project
    |> get_project_invite(email)
    |> DigitalPublicWorksWeb.Email.project_invite_email
    |> assert_delivered_email
  end

  @tag :as_user
  setup [:create_project]
  test "revoke invite", %{conn: conn, project: project} do
    project_invite = insert(:project_invite, project: project)

    conn = delete(conn, Routes.project_invite_path(conn, :delete, project, project_invite))

    assert redirected_to(conn) == Routes.project_invite_path(conn, :index, project)
    assert get_flash(conn, :info) =~ "Invite revoked."
  end

  @tag :as_user
  test "accept invite", %{conn: conn} do
    project_invite = insert(:project_invite)

    conn = get(conn, Routes.project_invite_path(conn, :update, project_invite))

    assert redirected_to(conn) == Routes.project_path(conn, :show, project_invite.project)
    assert get_flash(conn, :info) =~ "Joined project."
  end

  @tag :as_user
  test "invalid invite", %{conn: conn} do
    conn = get(conn, Routes.project_invite_path(conn, :update, "invalid"))

    assert redirected_to(conn) == Routes.page_path(conn, :index)
    assert get_flash(conn, :error) =~ "Invite not found."
  end
end
