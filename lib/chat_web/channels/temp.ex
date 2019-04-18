defmodule ChatWeb.Temp do
  def authenticate(username, token) do
    {:ok, encoded} = Jason.encode(%{username: username, token: token})

    case :httpc.request(
           :post,
           {'http://staging.cense.ai:8084/v1/chat/authenticate', [], 'application/json',
            '#{encoded}'},
           [],
           []
         ) do
      {:ok, res} ->
        {_, _, res} = res

        case Jason.decode(res) do
          {:ok, "token invalid"} ->
            {:error, %{reason: "invalid"}}

          {:ok, %{"Companyname" => company, "username" => username}} ->
            {:ok, %{company: company, username: username}}
        end

      _ ->
        {:error, %{reason: "invalid"}}
    end

    # {:ok, %{username: username, company: "MT Care"}}
  end
end
