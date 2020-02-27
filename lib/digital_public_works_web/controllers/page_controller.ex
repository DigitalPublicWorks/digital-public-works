defmodule DigitalPublicWorksWeb.PageController do
  use DigitalPublicWorksWeb, :controller
  alias DigitalPublicWorks.Projects

  def index(conn, _params) do
    conn
    |> assign(:featured_projects, Projects.list_featured_projects)
    |> assign(:followed_projects, Projects.list_followed_projects(conn.assigns.current_user))
    |> render("index.html")
  end

  def terms(conn, _params) do
    render(conn, "terms.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end
end
