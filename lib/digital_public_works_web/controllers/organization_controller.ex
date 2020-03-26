defmodule DigitalPublicWorksWeb.OrganizationController do
  use DigitalPublicWorksWeb, :controller

  alias DigitalPublicWorks.Repo

  plug DigitalPublicWorksWeb.Plugs.GetOrganization

  def show(conn, _params) do
    conn
    |> assign(:organization, conn.assigns.organization |> Repo.preload(projects: :user))
    |> render("show.html")
  end
end
