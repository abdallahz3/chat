defmodule ChatWeb.Plugs.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller

  def init(_params) do
  end

  def call(conn, _params) do
    conn = fetch_session(conn)

    case get_session(conn, :admin_username) do
      username when not is_nil(username) ->
        conn
        |> assign(:admin_username, username)

      nil ->
        conn
        |> json(%{error: "you need to login with admin account"})
        |> halt()
    end
  end
end
