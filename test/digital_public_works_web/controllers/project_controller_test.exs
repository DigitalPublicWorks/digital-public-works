defmodule DigitalPublicWorksWeb.ProjectControllerTest do
  use DigitalPublicWorksWeb.ConnCase

  @create_attrs %{body: "some body", title: "some title"}
  @update_attrs %{body: "some updated body", title: "some updated title"}
  @invalid_attrs %{body: nil, title: nil}

  describe "index" do
    test "lists all projects", %{conn: conn} do
      conn = get(conn, Routes.project_path(conn, :index))
      assert html_response(conn, 200) =~ ""
    end

    test "filters projects not specified by search", %{conn: conn} do
      project_title = "Milwaukee"
      insert(:project, title: project_title)
      conn = get(conn, Routes.project_path(conn, :index), project: %{q: project_title})
      assert html_response(conn, 200) =~ project_title
    end

    test "lists projects specified by search", %{conn: conn} do
      project_title = "Milwaukee"
      insert(:project, title: project_title)
      conn = get(conn, Routes.project_path(conn, :index), project: %{q: "Chicago"})
      refute html_response(conn, 200) =~ project_title
    end
  end

  describe "new project" do
    @tag :as_user
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.project_path(conn, :new))

      assert html_response(conn, 200) =~ "Create Project"
    end
  end

  describe "create project" do
    @tag :as_user
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.project_path(conn, :create), project: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.project_path(conn, :show, id)

      conn = get(conn, Routes.project_path(conn, :show, id))
      assert html_response(conn, 200) =~ @create_attrs.title
    end

    @tag :as_user
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.project_path(conn, :create), project: @invalid_attrs)

      assert html_response(conn, 200) =~ "Create Project"
    end
  end

  describe "edit project" do
    @tag :as_user
    test "renders form for editing chosen project", %{conn: conn, user: user} do
      project = insert(:project, user: user)

      conn = get(conn, Routes.project_path(conn, :edit, project))
      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  describe "update project" do
    @tag :as_user
    test "redirects when data is valid", %{conn: conn, user: user} do
      project = insert(:project, user: user)

      conn = put(conn, Routes.project_path(conn, :update, project), project: @update_attrs)

      assert redirected_to(conn) == Routes.project_path(conn, :show, project)

      conn = get(conn, Routes.project_path(conn, :show, project))
      assert html_response(conn, 200) =~ "some updated body"
    end

    @tag :as_user
    test "renders errors when data is invalid", %{conn: conn, user: user} do
      project = insert(:project, user: user)

      conn = put(conn, Routes.project_path(conn, :update, project), project: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  describe "delete project" do
    @tag :as_user
    test "deletes chosen project", %{conn: conn, user: user} do
      project = insert(:project, user: user)

      conn = delete(conn, Routes.project_path(conn, :delete, project))

      assert redirected_to(conn) == Routes.project_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.project_path(conn, :show, project))
      end
    end

    @tag :as_user
    test "can't delete project with followers", %{conn: conn, user: user} do
      project = insert(:project, user: user)
      user = insert(:user)

      DigitalPublicWorks.Projects.add_follower(project, user)

      conn = delete(conn, Routes.project_path(conn, :delete, project))

      assert redirected_to(conn) == Routes.project_path(conn, :edit, project)
      assert get_flash(conn, :error) =~ "You can't delete a project that has followers"
    end
  end

  describe "show project" do
    @tag :as_user
    test "shouldn't see edit button for someone else's project", %{conn: conn} do
      project = insert(:project)

      conn = get(conn, Routes.project_path(conn, :show, project))

      refute html_response(conn, 200) =~ "Edit"
    end

    @tag :as_user
    test "should see edit button for own project", %{conn: conn, user: user} do
      project = insert(:project, user: user)

      conn = get(conn, Routes.project_path(conn, :show, project))

      assert html_response(conn, 200) =~ "Edit"
    end

    @tag :as_user
    test "shouldn't see add update button for someone else's project", %{conn: conn} do
      project = insert(:project)

      conn = get(conn, Routes.project_path(conn, :show, project))

      refute html_response(conn, 200) =~ "Create Post"
    end

    @tag :as_user
    test "should see add update button for own project", %{conn: conn, user: user} do
      project = insert(:project, user: user)

      conn = get(conn, Routes.project_path(conn, :show, project))

      assert html_response(conn, 200) =~ "Create Post"
    end
  end

  describe "publish project" do
    @tag :as_user
    test  "user can't publish project", %{conn: conn, user: user} do
      project = insert(:project, user: user)

      conn = put(conn, Routes.project_path(conn, :publish, project))

      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert get_flash(conn, :error) =~ "You don't have access to that"
    end

    @tag :as_admin
    test  "admin can publish project", %{conn: conn} do
      project = insert(:project)

      conn = put(conn, Routes.project_path(conn, :publish, project))

      assert redirected_to(conn) == Routes.project_path(conn, :show, project)
      assert get_flash(conn, :info) =~ "Project published successfully"
    end
  end

  describe "unpublish project" do
    @tag :as_user
    test  "user can't unpublish project", %{conn: conn, user: user} do
      project = insert(:project, user: user, is_public: true)

      conn = put(conn, Routes.project_path(conn, :unpublish, project))

      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert get_flash(conn, :error) =~ "You don't have access to that"
    end

    @tag :as_admin
    test  "admin can unpublish project", %{conn: conn} do
      project = insert(:project, is_public: true)

      conn = put(conn, Routes.project_path(conn, :unpublish, project))

      assert redirected_to(conn) == Routes.project_path(conn, :show, project)
      assert get_flash(conn, :info) =~ "Project unpublished successfully"
    end
  end

  describe "follow project" do
    @tag :as_user
    test  "user can follow project", %{conn: conn} do
      project = insert(:project)

      conn = put(conn, Routes.project_path(conn, :follow, project))

      assert redirected_to(conn) == Routes.project_path(conn, :show, project)
      assert get_flash(conn, :info) =~ "Project followed"
    end
  end

  describe "unfollow project" do
    @tag :as_user
    test  "user can unfollow project", %{conn: conn, user: user} do
      project = insert(:project)
      DigitalPublicWorks.Projects.add_follower(project, user)

      conn = put(conn, Routes.project_path(conn, :unfollow, project))

      assert redirected_to(conn) == Routes.project_path(conn, :show, project)
      assert get_flash(conn, :info) =~ "Project unfollowed"
    end
  end

end
