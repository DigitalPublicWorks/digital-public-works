defmodule DigitalPublicWorksWeb.OrganizationController do
  use DigitalPublicWorksWeb, :controller

  alias DigitalPublicWorks.{Organizations, Repo}

  plug :get_organization

  defp get_organization(%{params: %{"slug" => slug}} = conn, _args) do
    case Organizations.get_organization_by_slug(slug) do
      nil ->
        conn
        |> put_flash(:error, "Organization not found")
        |> redirect(to: "/")
        |> halt()
      organization ->
        conn
        |> assign(:organization, organization)
    end
  end

  defp get_organization(conn, _args), do: conn

  def show(conn, _params) do
    conn
    |> assign(:organization, conn.assigns.organization |> Repo.preload(projects: :user))
    |> render("show.html")
  end
end
