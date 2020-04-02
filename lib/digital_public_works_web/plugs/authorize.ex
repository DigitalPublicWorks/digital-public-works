defmodule DigitalPublicWorksWeb.Plugs.Authorize do
  import Plug.Conn
  use DigitalPublicWorksWeb, :controller

  def init(current_resource), do: current_resource

  def call(conn, current_resource) do
    cond do
      can? conn.assigns[:current_user], action_name(conn), conn.assigns[current_resource] ->
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
end
