defmodule DigitalPublicWorksWeb.Plugs.GetProject do
  import Plug.Conn
  use Phoenix.Controller

  alias DigitalPublicWorks.Projects

  def init(slug_key), do: slug_key || "slug"

  def call(conn, slug_key) do
    conn |> assign(:project, get_project(conn.params[slug_key]))
  rescue
    _ -> conn |> not_found()
  end

  defp get_project(nil), do: raise("Not found")

  defp get_project(slug) do
    Projects.get_project_by_slug!(slug)
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
      |> URI.parse()

    "#{url.path}?#{url.query}"
  rescue
    _ -> "/"
  end
end
