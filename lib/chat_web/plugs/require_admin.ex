defmodule ChatWeb.Plugs.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller

  def init(_params) do
  end

  def call(conn, _params) do
    IO.puts "---------------------"
    IO.inspect conn.params
    IO.puts "---------------------"
    if Map.has_key?(conn.params, "token") do
      case Phoenix.Token.verify(ChatWeb.Endpoint, "salt", conn.params["token"], max_age: 86400) do
        {:ok, user} ->
          conn
          |> assign(:admin_username, user.username)

        {:error, reason} ->
          conn
          |> json(%{error: reason})
          |> halt()
      end
    else
      conn
      |> json(%{error: "you need to supply token"})
      |> halt()
    end
  end
end
