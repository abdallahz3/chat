defmodule ChatWeb.Router do
  use ChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ChatWeb do
    pipe_through :api

    get "/initialize-new-group", GroupController, :initialize_new_group
    post "/sync", PageController, :sync
  end

  scope "/api/admin", ChatWeb do
    pipe_through :api

    post "/login", AdminController, :login
    post "/create-group", AdminController, :create_group
    get "/get-groups", AdminController, :get_groups
    delete "/delete-group", AdminController, :delete_group
    post "/add-members-to-group", AdminController, :add_member_to_group
    post "/delete-members-from-group", AdminController, :delete_member_from_group
    get "/get-group-members", AdminController, :get_group_members
  end
end
