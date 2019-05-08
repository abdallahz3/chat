defmodule ChatWeb.Plugs.RequireLoggedIn do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller

  def init(params) do
    params
  end

  def call(conn, _params) do
    u = Map.get(conn.assigns, :user)

    if is_nil(u) do
      conn
      |> json(%{error: "you need to log in"})
      |> halt()
    else
      conn
    end
  end
end
