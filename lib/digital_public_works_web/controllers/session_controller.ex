defmodule DigitalPublicWorksWeb.SessionController do
  use DigitalPublicWorksWeb, :controller

  alias DigitalPublicWorks.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => auth_params}) do
    case Accounts.verify_user(auth_params) do
    {:ok, user} ->
      conn
      |> put_session(:current_user_id, user.id)
      |> configure_session(renew: true)
      |> put_flash(:info, "Signed in successfully.")
      |> redirect(to: Routes.project_path(conn, :index))
    {:error, _} ->
      conn
      |> put_flash(:error, "There was a problem with your username/password")
      |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Signed out successfully.")
    |> redirect(to: Routes.project_path(conn, :index))
  end
end
