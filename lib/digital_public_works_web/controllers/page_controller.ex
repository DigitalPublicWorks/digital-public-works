defmodule DigitalPublicWorksWeb.PageController do
  use DigitalPublicWorksWeb, :controller
  alias DigitalPublicWorks.Projects

  def index(conn, _params) do
    conn
    |> assign(:projects, Projects.list_featured_projects)
    |> render("index.html")
  end

  def terms(conn, _params) do
    render(conn, "terms.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end
end
