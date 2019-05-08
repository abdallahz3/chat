defmodule ChatWeb.LoginController do
  use ChatWeb, :controller
  import Ecto.Query, only: [from: 2]

  def login(conn, param) do
    case authenticate(param["username"], param["token"]) do
      {:ok, user} ->
        conn
        |> json(%{
          logged_in: "success",
          token: Phoenix.Token.sign(ChatWeb.Endpoint, "salt", user)
        })

      {:error, _} ->
        conn
        |> json(%{loggedin: "failed"})
    end
  end

  def authenticate(username, token) do
    #    {:ok, encoded} = Jason.encode(%{username: username, token: token})
    #
    #    case :httpc.request(
    #           :post,
    #           {'http://staging.cense.ai:8084/v1/chat/authenticate', [], 'application/json',
    #            '#{encoded}'},
    #           [],
    #           []
    #         ) do
    #      {:ok, res} ->
    #        {_, _, res} = res
    #
    #        case Jason.decode(res) do
    #          {:ok, "token invalid"} ->
    #            {:error, %{reason: "invalid"}}
    #
    #          {:ok, %{"Companyname" => company, "Role" => role, "username" => username}} ->
    #            {:ok, %{company: company, username: username, role: role}}
    #        end
    #
    #      _ ->
    #        {:error, %{reason: "invalid"}}
    #    end

    {:ok, %{company: "MT Care", role: "Admin", username: username}}
  end
end
