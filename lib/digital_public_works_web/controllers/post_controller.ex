defmodule DigitalPublicWorksWeb.PostController do
  use DigitalPublicWorksWeb, :controller

  alias DigitalPublicWorks.Posts
  alias DigitalPublicWorks.Posts.Post
  alias DigitalPublicWorks.Projects
  alias DigitalPublicWorks.Projects.Project

  plug :get_project
  plug :check_auth

  defp get_project(%{params: %{"project_id" => id}} = conn, _args) do
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

  def new(conn, _params) do
    conn
    |> assign(:changeset, Posts.change_post(%Post{}))
    |> assign(:action, Routes.project_post_path(conn, :create, conn.assigns.project))
    |> render("new.html")
  end

  def create(conn, %{"post" => post_params}) do
    project = conn.assigns.project
    current_user = conn.assigns.current_user

    case Posts.create_post(Map.merge(post_params, %{"user" => current_user, "project" => project})) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)

    conn
    |> assign(:post, post)
    |> assign(:changeset, Posts.change_post(post))
    |> render("edit.html")
  end

  def update(conn, %{"post" => post_params, "id" => id}) do
    post = Posts.get_post!(id)

    case Posts.update_post(post, post_params) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.project_path(conn, :show, conn.assigns.project))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> assign(:post, post)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)

    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.project_path(conn, :show, conn.assigns.project))
  end
end
