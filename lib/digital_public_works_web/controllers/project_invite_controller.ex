defmodule DigitalPublicWorksWeb.ProjectInviteController do
  use DigitalPublicWorksWeb, :controller

  alias DigitalPublicWorks.{Projects, Invites}
  alias DigitalPublicWorks.Repo
  alias DigitalPublicWorksWeb.{Email, Mailer}

  plug :get_project
  plug :get_project_invite
  plug :check_auth

  defp get_project(%{params: %{"project_slug" => slug}} = conn, _args) do
    conn |> assign(:project, Projects.get_project_by_slug!(slug))
  end

  defp get_project(%{params: %{"project_id" => id}} = conn, _args) do
    conn |> assign(:project, Projects.get_project!(id))
  end

  defp get_project(conn, _args), do: conn

  defp get_project_invite(%{params: %{"id" => id}} = conn, _args) do
    try do
      project_invite = Invites.get_project_invite!(id)

      project_invite =
        if project = conn.assigns[:project] do
          Map.put(project_invite, :project, project)
        else
          project_invite |> Repo.preload(:project)
        end

      conn |> assign(:project_invite, project_invite)
    rescue
      _ ->
        conn
        |> put_flash(:error, "Invite not found.")
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt()
    end
  end

  defp get_project_invite(conn, _args) do
    project = conn.assigns.project

    project_invite = Ecto.build_assoc(project, :project_invites, project: project)

    conn |> assign(:project_invite, project_invite)
  end

  defp check_auth(conn, _args) do
    cond do
      can?(conn.assigns.current_user, action_name(conn), conn.assigns.project_invite) ->
        conn

      conn.assigns.current_user ->
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

  def index(conn, _params) do
    project = conn.assigns.project

    conn
    |> assign(:project_invites, project |> project_invites)
    |> assign(:users, project |> project_users)
    |> assign(:changeset, Invites.change_project_invite())
    |> render("index.html")
  end

  def create(conn, %{"project_invite" => params}) do
    project = conn.assigns.project

    case Invites.create_project_invite(conn.assigns.project, params) do
      {:ok, project_invite} ->
        Email.project_invite_email(project_invite |> Map.put(:project, project)) |> Mailer.deliver_now

        conn
        |> put_flash(:info, "Invite sent.")
        |> redirect(to: Routes.project_invite_path(conn, :index, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> assign(:project_invites, project |> project_invites)
        |> assign(:users, project |> project_users)
        |> assign(:changeset, changeset)
        |> render("index.html")
    end
  end

  def update(conn, _params) do
    user = conn.assigns.current_user
    invite = conn.assigns.project_invite

    case Invites.update_project_invite(invite, user) do
      {:ok, _project_invite} ->
        conn
        |> put_flash(:info, "Joined project.")
        |> redirect(to: Routes.project_path(conn, :show, invite.project))
      {:error, changeset} ->
        error_message =
          changeset.errors
          |> Keyword.values
          |> Enum.map(&(elem(&1, 0)))
          |> Enum.join(", ")

        conn
        |> put_flash(:error, "Error joining project. #{error_message}.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def delete(conn, _params) do
    project = conn.assigns.project
    project_invite = conn.assigns.project_invite

    case Invites.delete_project_invite(project_invite) do
      {:ok, _project_invite} ->
        conn
        |> put_flash(:info, "Invite revoked.")
        |> redirect(to: Routes.project_invite_path(conn, :index, project))

      {:error, changeset} ->
        error_message =
          changeset.errors
          |> Keyword.values()
          |> Enum.map(&elem(&1, 0))
          |> Enum.join(", ")

        conn
        |> put_flash(:error, error_message)
        |> redirect(to: Routes.project_invite_path(conn, :index, project))
    end
  end

  defp project_invites(project) do
    project
    |> Ecto.assoc(:project_invites)
    |> Repo.all()
    |> Enum.map(&(Map.put(&1, :project, project)))
  end

  defp project_users(project) do
    project
    |> Ecto.assoc(:users)
    |> Repo.all()
  end
end
