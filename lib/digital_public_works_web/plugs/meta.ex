defmodule DigitalPublicWorks.Plugs.Meta do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _params) do
    assign(conn, :meta, %{
      title: "Digital Public Works",
      description: "A web platform for connecting civic projects with volunteers and mentors",
      keywords: "civic tech software programming",
      "og:url": build_url(conn)
    })
  end

  defp build_url(%Plug.Conn{scheme: scheme, host: host, port: port, request_path: path}) do 
    "#{scheme}://#{host}:#{port}#{path}"
  end
  defp build_url(%Plug.Conn{scheme: scheme, host: host, request_path: path}) do 
    "#{scheme}://#{host}#{path}"
  end

end
