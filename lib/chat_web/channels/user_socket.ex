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
        socket = assign(socket, :username, user.username)
        socket = assign(socket, :user_id, user.username)
        socket = assign(socket, :is_support_agent, true)
        socket = assign(socket, :company, user.company)

        {:ok, socket}

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

          {:ok, %{"Companyname" => company, "username" => username}} ->
            {:ok, %{company: company, username: username}}
        end

      _ ->
        {:error, %{reason: "invalid"}}
    end

    # {:ok, %{username: username, company: "MT Care"}}
  end

  # defp handle_in(nil, %{event: "toooooooz", topic: topic, ref: ref} = message, state, socket) do
  #   alias Phoenix.Socket.{Broadcast, Message, Reply}
  #   case socket.handler.__channel__(topic) do
  #     {channel, opts} ->
  #       case Phoenix.Channel.Server.join(socket, channel, message, opts) do
  #         {:ok, reply, pid} ->
  #           reply = %Reply{join_ref: ref, ref: ref, topic: topic, status: :ok, payload: reply}
  #           state = put_channel(state, pid, topic, ref)
  #           {:reply, :ok, encode_reply(socket, reply), {state, socket}}

  #         {:error, reply} ->
  #           reply = %Reply{join_ref: ref, ref: ref, topic: topic, status: :error, payload: reply}
  #           {:reply, :error, encode_reply(socket, reply), {state, socket}}
  #       end

  #     _ ->
  #       {:reply, :error, encode_ignore(socket, message), {state, socket}}
  #   end
  # end

  # defp handle_in(nil, %{event: "toooooooz", topic: topic, ref: ref} = message, state, socket) do
  #   alias Phoenix.Socket.{Broadcast, Message, Reply}
  #   case socket.handler.__channel__(topic) do
  #     {channel, opts} ->
  #       case Phoenix.Channel.Server.join(socket, channel, message, opts) do
  #         {:ok, reply, pid} ->
  #           reply = %Reply{join_ref: ref, ref: ref, topic: topic, status: :ok, payload: reply}
  #           state = put_channel(state, pid, topic, ref)
  #           {:reply, :ok, encode_reply(socket, reply), {state, socket}}

  #         {:error, reply} ->
  #           reply = %Reply{join_ref: ref, ref: ref, topic: topic, status: :error, payload: reply}
  #           {:reply, :error, encode_reply(socket, reply), {state, socket}}
  #       end

  #     _ ->
  #       {:reply, :error, encode_ignore(socket, message), {state, socket}}
  #   end
  # end

  # def handle_in(_, %{ref: ref, topic: "phoenix", event: "toz"}, state, socket) do
  #   IO.puts "Allah Akbar"
  #   alias Phoenix.Socket.{Reply}
  #   reply = %Reply{
  #     ref: ref,
  #     topic: "phoenix",
  #     status: :ok,
  #     payload: %{}
  #   }

  #   {:reply, :ok, encode_reply(socket, reply), {state, socket}}
  # end

  # defp put_channel(state, pid, topic, join_ref) do
  #   %{channels: channels, channels_inverse: channels_inverse} = state
  #   monitor_ref = Process.monitor(pid)

  #   %{
  #     state |
  #       channels: Map.put(channels, topic, {pid, monitor_ref}),
  #       channels_inverse: Map.put(channels_inverse, pid, {topic, join_ref})
  #   }
  # end

  # defp encode_reply(%{serializer: serializer}, message) do
  #   {:socket_push, opcode, payload} = serializer.encode!(message)
  #   {opcode, payload}
  # end

  # defp encode_ignore(%{handler: handler} = socket, %{ref: ref, topic: topic}) do
  #   require Logger
  #   alias Phoenix.Socket.{Broadcast, Message, Reply}
  #   Logger.warn fn -> "Ignoring unmatched topic \"#{topic}\" in #{inspect(handler)}" end
  #   reply = %Reply{ref: ref, topic: topic, status: :error, payload: %{reason: "unmatched topic"}}
  #   encode_reply(socket, reply)
  # end
end
