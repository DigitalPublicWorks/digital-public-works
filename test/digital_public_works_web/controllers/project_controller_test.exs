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
  end

  describe "new project" do
    test "renders form", %{conn: conn} do
      user = insert(:user)

      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> get(Routes.project_path(conn, :new))

      assert html_response(conn, 200) =~ "Submit a problem or project"
    end
  end

  describe "create project" do
    test "redirects to show when data is valid", %{conn: conn} do
      user = insert(:user)

      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> post(Routes.project_path(conn, :create), project: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.project_path(conn, :show, id)

      conn = get(conn, Routes.project_path(conn, :show, id))
      assert html_response(conn, 200) =~ "PROBLEM"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = insert(:user)

      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> post(Routes.project_path(conn, :create), project: @invalid_attrs)

      assert html_response(conn, 200) =~ "Submit a problem or project"
    end
  end

  describe "edit project" do
    test "renders form for editing chosen project", %{conn: conn} do
      project = insert(:project)
      user = project.user

      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> get(Routes.project_path(conn, :edit, project))
      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  describe "update project" do
    test "redirects when data is valid", %{conn: conn} do
      project = insert(:project)
      user = project.user

      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> put(Routes.project_path(conn, :update, project), project: @update_attrs)

      assert redirected_to(conn) == Routes.project_path(conn, :show, project)

      conn = get(conn, Routes.project_path(conn, :show, project))
      assert html_response(conn, 200) =~ "some updated body"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      project = insert(:project)
      user = project.user

      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> put(Routes.project_path(conn, :update, project), project: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  describe "delete project" do
    test "deletes chosen project", %{conn: conn} do
      project = insert(:project)
      user = project.user

      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> delete(Routes.project_path(conn, :delete, project))

      assert redirected_to(conn) == Routes.project_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.project_path(conn, :show, project))
      end
    end
  end
end
