defmodule DigitalPublicWorksWeb.PostController do
  use DigitalPublicWorksWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
