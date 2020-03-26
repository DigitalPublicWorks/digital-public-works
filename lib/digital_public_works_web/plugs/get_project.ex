defmodule DigitalPublicWorksWeb.Plugs.GetProject do
  import Plug.Conn
  use Phoenix.Controller

  alias DigitalPublicWorks.Projects

  def init(id_key), do: id_key || "id"

  def call(conn, id_key) do
    case get_project(conn.params[id_key]) do
      nil -> conn |> not_found()
      project -> conn |> assign(:project, project)
    end
  end

  defp get_project(nil), do: nil

  defp get_project(id) do
    Projects.get_project!(id)
  rescue
    _ -> nil
  end

  defp not_found(conn) do
    conn
    |> put_flash(:error, "Project not found")
    |> redirect(to: redirect_url(conn))
    |> halt()
  end

  defp redirect_url(conn) do
    url =
      conn
      |> Plug.Conn.get_req_header("referer")
      |> Enum.at(0)
      |> URI.parse

    "#{url.path}?#{url.query}"
  end
end
