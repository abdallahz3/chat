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

  pipeline :context do
    plug(ChatWeb.Plugs.Context)
  end

  pipeline :logged_in do
    plug(ChatWeb.Plugs.RequireLoggedIn)
  end

  pipeline :require_admin do
    plug(ChatWeb.Plugs.RequireAdmin)
  end

  scope "/", ChatWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ChatWeb do
    pipe_through :api

    post "/login", LoginController, :login
    get "/initialize-new-group", ApiController, :initialize_new_group
    post "/sync", ApiController, :sync
  end

  scope "/api/admin", ChatWeb do
    pipe_through [:context, :logged_in, :require_admin, :api]

    post "/create-group", AdminController, :create_group
    get "/get-groups", AdminController, :get_groups
    delete "/delete-group", AdminController, :delete_group
    post "/add-members-to-group", AdminController, :add_member_to_group
    post "/delete-members-from-group", AdminController, :delete_member_from_group
    get "/get-group-members", AdminController, :get_group_members
  end

  scope "/api", ChatWeb do
    pipe_through [:context, :logged_in, :api]

    get "/user/get-groups", UserController, :get_groups
    post "/user/create-peer-to-peer-group", UserController, :create_peer_to_peer_group
    get "/user/get-previous-messages-of-group", UserController, :get_previous_messages_of_group
  end
end
