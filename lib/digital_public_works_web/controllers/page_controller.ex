defmodule DigitalPublicWorksWeb.PageController do
  use DigitalPublicWorksWeb, :controller
  alias DigitalPublicWorks.Projects

  def index(conn, _params) do
    owned_projects = Projects.list_owned_projects(conn.assigns.current_user)
    followed_projects = Projects.list_followed_projects(conn.assigns.current_user)
    featured_projects = Projects.list_featured_projects -- followed_projects -- owned_projects

    conn
    |> assign(:owned_projects, owned_projects)
    |> assign(:followed_projects, followed_projects)
    |> assign(:featured_projects, featured_projects)
    |> render("index.html")
  end

  def terms(conn, _params) do
    render(conn, "terms.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end
end
