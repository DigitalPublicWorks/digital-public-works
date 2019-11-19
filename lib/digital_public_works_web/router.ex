defmodule DigitalPublicWorksWeb.Router do
  use DigitalPublicWorksWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug DigitalPublicWorks.Plugs.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DigitalPublicWorksWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/projects", ProjectController do
      resources "/posts", PostController
    end
    resources "/user", UserController, singleton: true
    resources "/session", SessionController, singleton: true
  end

  # Other scopes may use custom stacks.
  # scope "/api", DigitalPublicWorksWeb do
  #   pipe_through :api
  # end
end
