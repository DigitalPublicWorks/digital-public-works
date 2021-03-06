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

    get "/projects", ProjectController, :index
    get "/projects/new", ProjectController, :new

    resources "/p", ProjectController, [param: "slug", only: [:show, :create, :edit, :update, :delete]] do
      resources "/posts", PostController, only: [:new, :create, :edit, :update, :delete]
      resources "/invites", ProjectInviteController, only: [:index, :create, :delete], as: :invite
    end

    scope "/p/:slug" do
      put "/publish", ProjectController, :publish
      put "/unpublish", ProjectController, :unpublish
      put "/follow", ProjectController, :follow
      put "/unfollow", ProjectController, :unfollow
      put "/leave", ProjectController, :leave
      delete "/users/:user_id", ProjectController, :remove_user
      get "/about/edit", ProjectAboutController, :edit
      put "/about", ProjectAboutController, :update
    end

    get "/projects/:id", ProjectController, :show, as: :permalink_project

    get "/invites/:id", ProjectInviteController, :update

    resources "/user", UserController, singleton: true
    resources "/session", SessionController, singleton: true

    scope "/o/:slug" do
      get "/", OrganizationController, :show
      post "/projects", OrganizationController, :add_project
      delete "/projects", OrganizationController, :remove_project
    end
  end

  scope "/" do
    if Mix.env == :dev do
      forward "/sent_emails", Bamboo.SentEmailViewerPlug
    end
  end

  scope "/auth", DigitalPublicWorksWeb do
    pipe_through :browser

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
    post("/:provider/callback", AuthController, :callback)
  end

  # Other scopes may use custom stacks.
  # scope "/api", DigitalPublicWorksWeb do
  #   pipe_through :api
  # end
end
