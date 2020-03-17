defmodule DigitalPublicWorks.InvitesTest do
  use DigitalPublicWorks.DataCase

  describe "project_invites" do
    alias DigitalPublicWorks.{Invites, Projects}
    alias DigitalPublicWorks.Invites.ProjectInvite

    @valid_attrs %{email: "some email"}
    @invalid_attrs %{email: nil}

    def project_invite_fixture(attrs \\ %{}) do
      {:ok, project_invite} =
        Invites.create_project_invite(insert(:project), Enum.into(attrs, @valid_attrs))

      project_invite
    end

    test "list_project_invites/0 returns all project_invites" do
      project_invite = project_invite_fixture()
      assert Invites.list_project_invites() == [project_invite]
    end

    test "get_project_invite!/1 returns the project_invite with given id" do
      project_invite = project_invite_fixture()
      assert Invites.get_project_invite!(project_invite.id) == project_invite
    end

    test "create_project_invite/1 with valid data creates a project_invite" do
      assert {:ok, %ProjectInvite{} = project_invite} = Invites.create_project_invite(insert(:project), @valid_attrs)
      assert project_invite.email == "some email"
    end

    test "create_project_invite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invites.create_project_invite(insert(:project), @invalid_attrs)
    end

    test "update_project_invite/2 adds user to project and deletes project_invite " do
      project_invite = insert(:project_invite)
      user = insert(:user)

      assert {:ok, %ProjectInvite{} = project_invite} = Invites.update_project_invite(project_invite, user)
      assert Projects.is_user?(project_invite.project, user)
      assert_raise Ecto.NoResultsError, fn -> Invites.get_project_invite!(project_invite.id) end
    end

    test "update_project_invite/2 with invalid data returns error changeset" do
      project_invite = insert(:project_invite)
      user = insert(:user)
      Projects.add_user(project_invite.project, user)

      assert {:error, %Ecto.Changeset{}} = Invites.update_project_invite(project_invite, user)
      Invites.get_project_invite!(project_invite.id)
    end

    test "delete_project_invite/1 deletes the project_invite" do
      project_invite = project_invite_fixture()
      assert {:ok, %ProjectInvite{}} = Invites.delete_project_invite(project_invite)
      assert_raise Ecto.NoResultsError, fn -> Invites.get_project_invite!(project_invite.id) end
    end

    test "change_project_invite/1 returns a project_invite changeset" do
      project_invite = project_invite_fixture()
      assert %Ecto.Changeset{} = Invites.change_project_invite(project_invite)
    end
  end
end
