defmodule DigitalPublicWorks.AccountsTest do
  use DigitalPublicWorks.DataCase

  alias DigitalPublicWorks.Accounts

  describe "users" do
    alias DigitalPublicWorks.Accounts.User

    @valid_attrs %{email: "some email", password: "some password"}
    @update_attrs %{email: "some updated email", password: "some updated password"}
    @invalid_attrs %{email: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.password_hash != nil
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.password_hash != nil
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "project_invites" do
    alias DigitalPublicWorks.Accounts.ProjectInvite

    @valid_attrs %{email: "some email"}
    @update_attrs %{email: "some updated email"}
    @invalid_attrs %{email: nil}

    def project_invite_fixture(attrs \\ %{}) do
      {:ok, project_invite} =
        Accounts.create_project_invite(insert(:project), Enum.into(attrs, @valid_attrs))

      project_invite
    end

    test "list_project_invites/0 returns all project_invites" do
      project_invite = project_invite_fixture()
      assert Accounts.list_project_invites() == [project_invite]
    end

    test "get_project_invite!/1 returns the project_invite with given id" do
      project_invite = project_invite_fixture()
      assert Accounts.get_project_invite!(project_invite.id) == project_invite
    end

    test "create_project_invite/1 with valid data creates a project_invite" do
      assert {:ok, %ProjectInvite{} = project_invite} = Accounts.create_project_invite(insert(:project), @valid_attrs)
      assert project_invite.email == "some email"
    end

    test "create_project_invite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_project_invite(insert(:project), @invalid_attrs)
    end

    test "update_project_invite/2 with valid data updates the project_invite" do
      project_invite = project_invite_fixture()
      assert {:ok, %ProjectInvite{} = project_invite} = Accounts.update_project_invite(project_invite, @update_attrs)
      assert project_invite.email == "some updated email"
    end

    test "update_project_invite/2 with invalid data returns error changeset" do
      project_invite = project_invite_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_project_invite(project_invite, @invalid_attrs)
      assert project_invite == Accounts.get_project_invite!(project_invite.id)
    end

    test "delete_project_invite/1 deletes the project_invite" do
      project_invite = project_invite_fixture()
      assert {:ok, %ProjectInvite{}} = Accounts.delete_project_invite(project_invite)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_project_invite!(project_invite.id) end
    end

    test "change_project_invite/1 returns a project_invite changeset" do
      project_invite = project_invite_fixture()
      assert %Ecto.Changeset{} = Accounts.change_project_invite(project_invite)
    end
  end
end
