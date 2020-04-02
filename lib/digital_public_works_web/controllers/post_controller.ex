defmodule DigitalPublicWorksWeb.PostController do
  use DigitalPublicWorksWeb, :controller

  alias DigitalPublicWorks.Posts
  alias DigitalPublicWorks.Posts.Post
  alias DigitalPublicWorks.Projects
  alias DigitalPublicWorks.Projects.Project

  plug :get_project
  plug :get_post
  plug :check_auth

  defp get_project(%{params: %{"project_slug" => slug}} = conn, _args) do
    conn |> assign(:project, Projects.get_project_by_slug!(slug))
  end

  defp get_project(%{params: %{"project_id" => id}} = conn, _args) do
    conn |> assign(:project, Projects.get_project!(id))
  end

  defp get_project(conn, _args) do
    conn |> assign(:project, %Project{})
  end

  defp get_post(%{params: %{"id" => id}} = conn, _args) do
    conn |> assign(:post, Posts.get_post!(id))
  end

  defp get_post(conn, _args) do
    conn |> assign(:post, %Post{project: conn.assigns.project})
  end

  defp check_auth(conn, _args) do
    cond do
      can? conn.assigns.current_user, action_name(conn), conn.assigns.post ->
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
    |> assign(:changeset, Posts.change_post(conn.assigns.post))
    |> render("new.html")
  end

  def create(conn, %{"post" => post_params}) do
    project = conn.assigns.project
    current_user = conn.assigns.current_user

    post_params = Map.merge(post_params, %{"user_id" => current_user.id, "project_id" => project.id})

    case Posts.create_post(post_params) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    post = conn.assigns.post

    conn
    |> assign(:post, post)
    |> assign(:changeset, Posts.change_post(post))
    |> render("edit.html")
  end

  def update(conn, %{"post" => post_params}) do
    post = conn.assigns.post

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

  def delete(conn, _params) do
    post = conn.assigns.post

    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.project_path(conn, :show, conn.assigns.project))
  end
end
