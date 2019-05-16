defmodule ChatWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "customers_groups:*", ChatWeb.CustomerGroup
  channel "companies:*", ChatWeb.SupportAgentsGroup
  channel "groups:*", ChatWeb.Group

  def connect(
        %{"username" => username, "token" => token},
        socket,
        _connect_info
      ) do
    case authenticate(username, token) do
      {:ok, user} ->
        socket = assign(socket, :user, user)
        {:ok, socket}

      {:error, reason} ->
        :error
    end
  end

  def connect(
        %{"company" => company, "token" => token},
        socket,
        _connect_info
      ) do
    IO.inspect(socket)

    case Phoenix.Token.verify(ChatWeb.Endpoint, "salt", token, max_age: 86400) do
      {:ok, customer_group_name} ->
        user = %{
          company: company,
          customer_group_name: customer_group_name,
          is_customer: true,
          name: nil
        }

        socket = assign(socket, :user, user)

        {:ok, socket}

      {:error, reason} ->
        :error
    end
  end

  def connect(_param, _socket, _connect_info) do
    :error
  end

  def id(socket), do: nil

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

             {:ok, user} ->
               {:ok, %{company: user["Companyname"], username: user["username"], role: user["Role"]}}
           end

         _ ->
           {:error, %{reason: "invalid"}}
       end

    # {:ok, %{username: username, company: "MT Care", role: "User"}}
  end
end
