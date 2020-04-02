defmodule DigitalPublicWorksWeb.PostControllerTest do
  use DigitalPublicWorksWeb.ConnCase

  @create_attrs %{title: "Test Post", body: "Test Post Body"}
  @update_attrs %{title: "Updated Post", body: "Updated Post Body"}
  @invalid_attrs %{}

  describe "new post" do
    @tag :as_user
    test "renders form", %{conn: conn, user: user} do
      project = insert(:project, user: user)

      conn = get(conn, Routes.project_post_path(conn, :new, project))

      assert html_response(conn, 200) =~ "New Post"
    end

    test "prevent non-owners from viewing form", %{conn: conn} do
      project = insert(:project)

      conn = get(conn, Routes.project_post_path(conn, :new, project))

      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "create post" do
    @tag :as_user
    test "redirects to project show when data is valid", %{conn: conn, user: user} do
      project = insert(:project, user: user)

      conn = post(conn, Routes.project_post_path(conn, :create, project), post: @create_attrs)

      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == Routes.project_path(conn, :show, slug)

      conn = get(conn, Routes.project_path(conn, :show, slug))
      assert html_response(conn, 200) =~ "Test Post"
    end

    @tag :as_user
    test "renders errors when data is invalid", %{conn: conn, user: user} do
      project = insert(:project, user: user)

      conn = post(conn, Routes.project_post_path(conn, :create, project), post: @invalid_attrs)

      assert html_response(conn, 200) =~ "Create Post"
    end

    test "prevent non-owners from creating post", %{conn: conn} do
      project = insert(:project)

      conn = post(conn, Routes.project_post_path(conn, :create, project), post: @create_attrs)

      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "edit project" do
    @tag :as_user
    test "renders form for editing chosen project", %{conn: conn, user: user} do
      project = insert(:project, user: user)
      post = insert(:post, project: project, user: user)

      conn = get(conn, Routes.project_post_path(conn, :edit, project, post))
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "update post" do
    @tag :as_user
    test "redirects to project show when data is valid", %{conn: conn, user: user} do
      project = insert(:project, user: user)
      post = insert(:post, project: project, user: user)

      conn = put(conn, Routes.project_post_path(conn, :update, project, post), post: @update_attrs)

      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == Routes.project_path(conn, :show, slug)

      conn = get(conn, Routes.project_path(conn, :show, slug))
      assert html_response(conn, 200) =~ "Updated Post"
    end

    @tag :as_user
    test "renders errors when data is invalid", %{conn: conn, user: user} do
      project = insert(:project, user: user)
      post = insert(:post, project: project, user: user)

      conn = put(conn, Routes.project_post_path(conn, :update, project, post), post: @invalid_attrs)

      assert html_response(conn, 200) =~ "Update Post"
    end

    test "prevent non-owners from updating a post", %{conn: conn} do
      post = insert(:post)

      conn = put(conn, Routes.project_post_path(conn, :update, post.project, post), post: @update_attrs)

      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "delete post" do
    @tag :as_user
    test "deletes chosen project", %{conn: conn, user: user} do
      project = insert(:project, user: user)
      post = insert(:post, project: project, user: user)

      conn = delete(conn, Routes.project_post_path(conn, :delete, project, post))

      assert redirected_to(conn) == Routes.project_path(conn, :show, project)
    end

    test "prevent non-owners from deleting a post", %{conn: conn} do
      post = insert(:post)

      conn = delete(conn, Routes.project_post_path(conn, :delete, post.project, post))

      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

end
