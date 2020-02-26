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
    get "/terms", PageController, :terms
    get "/privacy", PageController, :privacy

    resources "/projects", ProjectController do
      resources "/posts", PostController, only: [:new, :create, :edit, :update, :delete]
    end

    scope "/projects/:id" do
      put "/publish", ProjectController, :publish
      put "/unpublish", ProjectController, :unpublish
    end

    resources "/user", UserController, singleton: true
    resources "/session", SessionController, singleton: true
  end

  scope "/" do
    if Mix.env == :dev do
      forward "/sent_emails", Bamboo.SentEmailViewerPlug
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", DigitalPublicWorksWeb do
  #   pipe_through :api
  # end
end
