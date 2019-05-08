defmodule ChatWeb.Plugs.Context do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller

  def init(opts) do
    opts
  end

  # TODO refactor
  def call(conn, _opts) do
    token = conn.params["token"]

    if token != nil do
      case Phoenix.Token.verify(ChatWeb.Endpoint, "salt", token, max_age: 86400) do
        {:ok, user} ->
          #          IO.inspect user
          conn
          |> assign(:user, user)

        {:error, reason} ->
          conn
          |> json(%{error: reason})
          |> halt()
      end
    else
      conn
    end
  end
end
