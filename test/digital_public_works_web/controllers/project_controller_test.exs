defmodule DigitalPublicWorksWeb.ProjectControllerTest do
  use DigitalPublicWorksWeb.ConnCase

  alias DigitalPublicWorks.{Projects, Accounts}

  @create_attrs %{body: "some body", title: "some title"}
  @update_attrs %{body: "some updated body", title: "some updated title"}
  @invalid_attrs %{body: nil, title: nil}

  def fixture(:project) do
    {:ok, project} = Projects.create_project(@create_attrs)
    project
  end

  describe "index" do
    test "lists all projects", %{conn: conn} do
      conn = get(conn, Routes.project_path(conn, :index))
      assert html_response(conn, 200) =~ ""
    end
  end

  describe "new project" do
    setup [:create_user]

    test "renders form", %{conn: conn, user: user} do
      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> get(Routes.project_path(conn, :new))

      assert html_response(conn, 200) =~ "Submit a problem or project"
    end
  end

  describe "create project" do
    setup [:create_user]

    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> post(Routes.project_path(conn, :create), project: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.project_path(conn, :show, id)

      conn = get(conn, Routes.project_path(conn, :show, id))
      assert html_response(conn, 200) =~ "PROBLEM"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> post(Routes.project_path(conn, :create), project: @invalid_attrs)

      assert html_response(conn, 200) =~ "Submit a problem or project"
    end
  end

  describe "edit project" do
    setup [:create_project, :create_user]

    test "renders form for editing chosen project", %{conn: conn, project: project, user: user} do
      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> get(Routes.project_path(conn, :edit, project))
      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  describe "update project" do
    setup [:create_project, :create_user]

    test "redirects when data is valid", %{conn: conn, project: project, user: user} do
      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> put(Routes.project_path(conn, :update, project), project: @update_attrs)

      assert redirected_to(conn) == Routes.project_path(conn, :show, project)

      conn = get(conn, Routes.project_path(conn, :show, project))
      assert html_response(conn, 200) =~ "some updated body"
    end

    test "renders errors when data is invalid", %{conn: conn, project: project, user: user} do
      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> put(Routes.project_path(conn, :update, project), project: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  describe "delete project" do
    setup [:create_project]

    test "deletes chosen project", %{conn: conn, project: project} do
      {:ok, user} = create_user(conn)

      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> delete(Routes.project_path(conn, :delete, project))

      assert redirected_to(conn) == Routes.project_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.project_path(conn, :show, project))
      end
    end
  end

  defp create_project(_) do
    project = fixture(:project)
    {:ok, project: project}
  end

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(%{email: "test@example.com", password: "test1234"})
    {:ok, user: user}
  end
end
