defmodule ChatWeb.UserSocket do
  # def handle_in(m, state) do
  #   IO.puts("Allah Akbar")
  #   IO.inspect(m)
  #   IO.inspect(state)
  #   Phoenix.Socket.__in__(m, state)
  # end

  # def handle_info(message, state) do
  #   IO.puts("Allah Akbar")
  #   IO.inspect(message)
  #   IO.inspect(state)
  #   Phoenix.Socket.__info__(message, state)
  # end

  use Phoenix.Socket

  ## Channels
  channel "customers_groups:*", ChatWeb.CustomerGroup
  # user means like a combany that has support agents
  # support agents will subscribe to their company's channel to get
  # notification of customers who need support
  # each company has a group of its support agents
  channel "companies:*", ChatWeb.SupportAgentGroup
  channel "groups:*", ChatWeb.Group
  # channel "admins:*", ChatWeb.AdminGroup

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"username" => username, "token" => token}, socket, _connect_info) do
    IO.puts("it is a support agent")

    case authenticate(username, token) do
      {:ok, user} ->
        case user.role do
          "admin" ->
            socket = assign(socket, :username, user.username)
            socket = assign(socket, :user_id, user.username)
            socket = assign(socket, :is_admin, true)

            {:ok, socket}

          "support_agent" ->
            socket = assign(socket, :username, user.username)
            socket = assign(socket, :user_id, user.username)
            socket = assign(socket, :company, user.company)
            socket = assign(socket, :is_admin, false)
            socket = assign(socket, :is_support_agent, true)

            {:ok, socket}

          _ ->
            socket = assign(socket, :username, user.username)
            socket = assign(socket, :user_id, user.username)
            socket = assign(socket, :company, user.company)
            socket = assign(socket, :is_admin, false)
            socket = assign(socket, :is_support_agent, false)

            {:ok, socket}
        end

      {:error, _} ->
        :error
    end

    # ChatWeb.GroupChat.join("chat_groups:test", %{}, socket)
    # {:ok, socket}
  end

  def connect(
        %{"company" => company, "chat_group_name" => chat_group_name, "token" => token},
        socket,
        _connect_info
      ) do
    IO.inspect(self())

    case Phoenix.Token.verify(ChatWeb.Endpoint, "salt", token, max_age: 86400) do
      {:ok, chat_group_name} ->
        socket = assign(socket, :is_support_agent, false)
        socket = assign(socket, :company, company)
        socket = assign(socket, :user_id, chat_group_name)
        socket = assign(socket, :chat_group_name, chat_group_name)

        {:ok, socket}

      {:error, reason} ->
        IO.inspect(reason)
        :error
    end
  end

  def connect(_param, _socket, _connect_info) do
    :error
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ChatWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  # def id(_socket), do: nil
  def id(socket), do: "users_socket:#{socket.assigns.user_id}"

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

    # {:ok, %{username: username, company: "MT Care"}}
  end
end
