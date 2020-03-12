defmodule DigitalPublicWorksWeb.PageController do
  use DigitalPublicWorksWeb, :controller
  alias DigitalPublicWorks.{Projects, Posts}

  def index(%{assigns: %{current_user: current_user}} = conn, _params) when current_user != nil do
    user = conn.assigns.current_user

    owned_projects = Projects.list_owned_projects(user)
    followed_projects = Projects.list_followed_projects(user)
    joined_projects = Projects.list_joined_projects(user)

    posts = Posts.list_posts(owned_projects ++ followed_projects ++ joined_projects)

    conn
    |> assign(:owned_projects, owned_projects)
    |> assign(:followed_projects, followed_projects)
    |> assign(:joined_projects, joined_projects)
    |> assign(:posts, posts)
    |> render("index_user.html")
  end

  def index(conn, _params) do
    featured_projects = Projects.list_featured_projects

    conn
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
