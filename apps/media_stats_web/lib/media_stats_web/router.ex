defmodule MediaStatsWeb.Router do
  use MediaStatsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug MediaStatsWeb.Plug.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MediaStatsWeb do
    pipe_through :browser

    get "/", PageController, :index

    # Session
    get    "/login", SessionController, :login
    post   "/login", SessionController, :login
    delete "/logout", SessionController, :logout

    #User
    get  "/sign-up", UserController, :sign_up
    post "/sign-up", UserController, :sign_up
  end

  scope "/dashboard", MediaStatsWeb do
    pipe_through [:browser, :authenticate_user]

    get "/", DashboardController, :index
    get "/pusher", DashboardController, :pusher
  end

  scope "/applications", MediaStatsWeb do
    pipe_through [:browser, :authenticate_user]

    resources "/", ApplicationController, only: [:new, :create, :edit, :update]
  end

  # Other scopes may use custom stacks.
  # scope "/api", MediaStatsWeb do
  #   pipe_through :api
  # end
end
