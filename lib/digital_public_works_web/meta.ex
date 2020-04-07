defmodule DigitalPublicWorksWeb.Meta do
  def meta(conn, key, value) do
    meta = Map.put(conn.assigns[:meta], key, value)
    Plug.Conn.assign(conn, :meta, meta)
  end
end

