defmodule DigitalPublicWorksWeb.ProjectAboutController do
  use DigitalPublicWorksWeb, :controller
  alias DigitalPublicWorks.Projects

  plug :get_project
  plug :check_auth

  defp get_project(%{params: %{"slug" => slug}} = conn, _args) do
    conn |> assign(:project, Projects.get_project_by_slug!(slug))
  end

  defp get_project(%{params: %{"id" => id}} = conn, _args) do
    conn |> assign(:project, Projects.get_project!(id))
  end

  defp check_auth(conn, _args) do
    cond do
      can? conn.assigns.current_user, action_name(conn), conn.assigns.project ->
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

  def edit(conn, _params) do
    project = conn.assigns.project

    conn
    |> assign(:project, project)
    |> assign(:changeset, Projects.change_project(project))
    |> assign(:action, Routes.project_about_path(conn, :update, project))
    |> render("edit.html")
  end

  def update(conn, %{"project" => project_params}) do
    project = conn.assigns.project

    Projects.update_project(project, project_params)

    conn
    |> put_flash(:info, "Project updated successfully.")
    |> redirect(to: Routes.project_path(conn, :show, project))
  end

end
