defmodule DigitalPublicWorks.ProjectsTest do
  use DigitalPublicWorks.DataCase

  alias DigitalPublicWorks.Projects
  alias DigitalPublicWorks.Projects.Project
  alias DigitalPublicWorks.Posts

  describe "projects" do
    @valid_attrs %{body: "some body", title: "some title"}
    @update_attrs %{body: "some updated body", title: "some updated title"}
    @invalid_attrs %{body: nil, title: nil}

    test "list_projects/2 returns all projects" do
      owner = insert(:user)
      other = insert(:user)
      admin = insert(:user, is_admin: true)

      project = Projects.get_project!(insert(:project, user: owner).id)

      assert Projects.list_projects(owner) == [project]
      assert Projects.list_projects(admin) == [project]
      assert Projects.list_projects(other) == []
      assert Projects.list_projects        == []

      project = project
      |> Ecto.Changeset.change(is_public: true)
      |> Repo.update!

      assert Projects.list_projects(owner) == [project]
      assert Projects.list_projects(admin) == [project]
      assert Projects.list_projects(other) == [project]
      assert Projects.list_projects        == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = insert(:project)
      assert Projects.get_project!(project.id).id == project.id
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
      project = Projects.get_project!(insert(:project).id)
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = insert(:project)
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "delete_project/1 raises error when project has followers" do
      project = insert(:project)
      user = insert(:user)

      Projects.add_follower(project, user)

      assert {:error, %Ecto.Changeset{} } = Projects.delete_project(project)
    end

    test "delete_project/1 deleting project also deletes posts" do
      %{project: project, id: post_id}  = insert(:post)

      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post_id) end
    end

    test "change_project/1 returns a project changeset" do
      project = insert(:project)
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end

    test "follow and unfollow project" do
      user = insert(:user)
      project = Projects.get_project!(insert(:project).id)

      assert Ecto.assoc(user, :followed_projects) |> Repo.all == []
      assert Projects.is_follower?(project, user) == false

      Projects.add_follower(project, user)
      assert Projects.list_followed_projects(user) == [project]
      assert Projects.is_follower?(project, user) == true

      Projects.remove_follower(project, user)
      assert Ecto.assoc(user, :followed_projects) |> Repo.all == []
      assert Projects.is_follower?(project, user) == false
    end

    test "add and remove user" do
      user = insert(:user)
      project = Projects.get_project!(insert(:project).id)

      assert Ecto.assoc(user, :joined_projects) |> Repo.all == []
      assert Projects.is_user?(project, user) == false

      Projects.add_user(project, user)
      assert Ecto.assoc(user, :joined_projects) |> Repo.all |> Repo.preload(:user) == [project]
      assert Projects.is_user?(project, user) == true

      Projects.remove_user(project, user)
      assert Ecto.assoc(user, :joined_projects) |> Repo.all == []
      assert Projects.is_user?(project, user) == false
    end
  end

  describe "project slugs" do
    test "slug is created automatically" do
      {:ok, project} = Projects.create_project(insert(:user), %{title: "Hello World!", body: "test"})

      assert project.slug == "hello-world"
    end

    test "project can be looked up by last 10 slugs" do
      project = insert(:project) |> reload()

      original_slug = project.slug
      original_title = project.title

      assert project == Projects.get_project_by_slug!(original_slug)

      for i <- 0..9 do
        {:ok, _} = Projects.update_project(project, %{title: "#{original_title} #{i}"})
      end

      project = project |> reload()

      for i <- 0..9 do
        assert project == Projects.get_project_by_slug!("#{original_slug}-#{i}")
      end

      assert_raise Ecto.NoResultsError, fn -> Projects.get_project_by_slug!(original_slug) end
    end

    test "project can't use the same slug as another project" do
      Projects.create_project(insert(:user), %{title: "Hello World", body: "test"})
      {:error, %Ecto.Changeset{}} = Projects.create_project(insert(:user), %{title: "Hello World!!!", body: "test"})
    end

    test "project can't use old slug of another project" do
      p1 = insert(:project) |> reload()
      p2 = insert(:project) |> reload()

      old_slug = p1.slug

      {:ok, p1} = Projects.update_project(p1, %{title: "Hello World!"})

      refute p1.slug == old_slug

      {:error, %Ecto.Changeset{}} = Projects.update_project(p2, %{title: old_slug})
    end
  end
end
