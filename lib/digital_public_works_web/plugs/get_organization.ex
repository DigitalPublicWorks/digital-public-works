defmodule DigitalPublicWorksWeb.Plugs.GetOrganization do
  import Plug.Conn
  use Phoenix.Controller

  alias DigitalPublicWorks.Organizations

  def init(opts), do: opts

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
