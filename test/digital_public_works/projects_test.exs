defmodule DigitalPublicWorks.ProjectsTest do
  use DigitalPublicWorks.DataCase

  alias DigitalPublicWorks.Projects
  alias DigitalPublicWorks.Projects.Project

  import DigitalPublicWorks.Factory

  describe "projects" do
    @valid_attrs %{body: "some body", title: "some title"}
    @update_attrs %{body: "some updated body", title: "some updated title"}
    @invalid_attrs %{body: nil, title: nil}

    test "list_projects/0 returns all projects" do
      project = Repo.get(Project, insert(:project).id)
      assert Projects.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = Repo.get(Project, insert(:project).id)
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      user = insert(:user)
      assert {:ok, %Project{} = project} = Projects.create_project(user, @valid_attrs)
      assert project.body == "some body"
      assert project.title == "some title"
    end

    test "create_project/1 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(user, @invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = insert(:project)
      assert {:ok, %Project{} = project} = Projects.update_project(project, @update_attrs)
      assert project.body == "some updated body"
      assert project.title == "some updated title"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = Repo.get(Project, insert(:project).id)
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = insert(:project)
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = insert(:project)
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end
end
