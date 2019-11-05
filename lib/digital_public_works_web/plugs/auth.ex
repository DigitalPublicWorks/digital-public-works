defmodule DigitalPublicWorks.Plugs.Auth do 
  import Plug.Conn

  alias DigitalPublicWorks.Accounts

  def init(opts), do: opts

  def call(conn, _params) do
    if conn.assigns[:current_user] do
      conn
    else
      current_user = if user_id = get_session(conn, :current_user_id) do
        Accounts.get_user!(user_id)
      end

      conn
      |> assign(:current_user, current_user)
    end
  end

end