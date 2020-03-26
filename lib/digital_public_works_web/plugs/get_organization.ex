defmodule DigitalPublicWorksWeb.Plugs.GetOrganization do
  import Plug.Conn
  use Phoenix.Controller

  alias DigitalPublicWorks.Organizations

  def init(id_key), do: id_key || "id"

  def call(%{params: %{"slug" => slug}} = conn, _args) do
    case Organizations.get_organization_by_slug(slug) do
      nil ->
        conn |> not_found()

      organization ->
        conn |> assign(:organization, organization)
    end
  end

  def call(conn, _args), do: conn

  defp not_found(conn) do
    conn
    |> put_flash(:error, "Organization not found")
    |> redirect(to: "/")
    |> halt()
  end
end
