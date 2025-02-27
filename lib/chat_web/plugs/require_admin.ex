defmodule ChatWeb.Plugs.RequireAdmin do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller

  def init(params) do
    params
  end

  def call(conn, _params) do
    if conn.assigns.user.role == "Admin" do
      conn
    else
      conn
      |> json(%{error: "you are NOT Admin"})
      |> halt()
    end
  end
end
