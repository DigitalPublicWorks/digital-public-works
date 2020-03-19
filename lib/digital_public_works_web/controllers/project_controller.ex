defmodule DigitalPublicWorksWeb.ProjectController do
  use DigitalPublicWorksWeb, :controller

  alias DigitalPublicWorks.{Projects, Posts, Accounts}
  alias DigitalPublicWorks.Projects.Project

  plug :get_project
  plug :check_auth

  defp get_project(%{params: %{"id" => id}} = conn, _args) do
    conn |> assign(:project, Projects.get_project!(id))
  end

  defp get_project(conn, _args) do
    conn |> assign(:project, %Project{})
  end

  defp check_auth(conn, _args) do
    cond do
      can? conn.assigns[:current_user], action_name(conn), conn.assigns[:project] ->
        conn
      conn.assigns[:current_user] ->
        conn
        |> put_flash(:error, "You don't have access to that")
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt()
      true ->
        conn
        |> put_flash(:info, "You need to log in first")
        |> redirect(to: Routes.session_path(conn, :new))
        |> halt()
    end
  end

  def index(conn, params) do
    search = params["project"]["q"]

    projects = Projects.list_projects(conn.assigns.current_user, search)

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

  def show(conn, _params) do
    conn
    |> assign(:posts, Posts.list_posts(conn.assigns.project))
    |> render("show.html")
  end

  def edit(conn, _params) do
    project = conn.assigns.project
    changeset = Projects.change_project(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end

  def update(conn, %{"project" => project_params}) do
    project = conn.assigns.project

    case Projects.update_project(project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    project = conn.assigns.project

    case Projects.delete_project(project) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project deleted successfully.")
        |> redirect(to: Routes.project_path(conn, :index))

      {:error, changeset} ->
        error_message =
          changeset.errors
          |> Keyword.values
          |> Enum.map(&(elem(&1, 0)))
          |> Enum.join(", ")

        conn
        |> put_flash(:error, error_message)
        |> redirect(to: Routes.project_path(conn, :edit, project))
    end
  end

  def publish(conn, _params) do
    project = conn.assigns.project

    {:ok, _project} = Projects.publish_project(project)

    conn
    |> put_flash(:info, "Project published successfully.")
    |> redirect(to: Routes.project_path(conn, :show, project))
  end

  def unpublish(conn, _params) do
    project = conn.assigns.project

    {:ok, _project} = Projects.unpublish_project(project)

    conn
    |> put_flash(:info, "Project unpublished successfully.")
    |> redirect(to: Routes.project_path(conn, :show, project))
  end

  def follow(conn, _params) do
    project = conn.assigns.project
    user = conn.assigns.current_user

    {:ok, _} = Projects.add_follower(project, user)

    conn
    |> put_flash(:info, "Project followed.")
    |> redirect(to: Routes.project_path(conn, :show, project))
  end

  def unfollow(conn, _params) do
    project = conn.assigns.project
    user = conn.assigns.current_user

    Projects.remove_follower(project, user)

    conn
    |> put_flash(:info, "Project unfollowed.")
    |> redirect(to: Routes.project_path(conn, :show, project))
  end

  def leave(conn, _params) do
    project = conn.assigns.project
    user = conn.assigns.current_user

    Projects.remove_user(project, user)

    conn
    |> put_flash(:info, "Left project.")
    |> redirect(to: Routes.project_path(conn, :show, project))
  end

  def remove_user(conn, %{"user_id" => user_id}) do
    project = conn.assigns.project
    user = Accounts.get_user!(user_id)

    Projects.remove_user(project, user)

    conn
    |> put_flash(:info, "Removed user.")
    |> redirect(to: Routes.project_invite_path(conn, :index, project))
  end
end
