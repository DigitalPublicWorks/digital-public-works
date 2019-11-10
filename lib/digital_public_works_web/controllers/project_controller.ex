defmodule DigitalPublicWorksWeb.ProjectController do
  use DigitalPublicWorksWeb, :controller

  alias DigitalPublicWorks.Projects
  alias DigitalPublicWorks.Projects.Project

  plug :check_auth when action in [:new, :create, :edit, :update, :delete]

  defp check_auth(conn, _args) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You need to be signed in to access that page.")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end

  def index(conn, _params) do
    projects = Projects.list_projects()
    render(conn, "index.html", projects: projects)
  end

  def new(conn, _params) do
    changeset = Projects.change_project(%Project{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    case Projects.create_project(conn.assigns.current_user, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    render(conn, "show.html", project: project)
  end

  def edit(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    changeset = Projects.change_project(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Projects.get_project!(id)

    case Projects.update_project(project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    {:ok, _project} = Projects.delete_project(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: Routes.project_path(conn, :index))
  end
end
