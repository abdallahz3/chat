defmodule ChatWeb.Group do
  use ChatWeb, :channel
  alias Chat.Repo
  alias ChatWeb.Presence
  import Ecto.Query, only: [from: 2]

  def join("groups:" <> group_name, _params, socket) do
    if String.contains?(group_name, "|") do
      # one to one chat
      [u1, u2] = String.split(group_name, "|")

      if socket.assigns.user.username != u1 and socket.assigns.user.username != u2 do
        {:error, %{reason: "You are not in this Group"}}
      else
        send(self(), {:after_join, group_name})
        {:ok, socket}
      end
    else
      case Repo.get_by(Chat.Group, group_name: group_name) do
        nil ->
          {:error, %{reason: "Group does not exist"}}

        group ->
          case from(g in Chat.GroupMember,
                 where:
                   g.group_name == ^group.group_name and g.member_id == ^socket.assigns.user.username,
                 select: g
               )
               |> Chat.Repo.all() do
            [] ->
              {:error, %{reason: "You are not in the Group"}}

            [_member] ->
              IO.puts("member #{socket.assigns.user.username} joined")
              send(self(), {:after_join, group_name})
              {:ok, socket}
          end
      end
    end
  end

  def handle_info({:after_join, group_name}, socket) do
    push(socket, "presence_state", Presence.list(socket))

    {:ok, _} =
      Presence.track(socket, socket.assigns.user.username, %{
        online_at: inspect(System.system_time(:second))
      })

    {:noreply, socket}
  end

  def handle_in("new_chat_message", %{"message" => message}, socket) do
    IO.puts(message)

    broadcast!(socket, "new_chat_message", %{
      message: message,
      sender: socket.assigns.user.username
    })

    {:noreply, socket}
  end

  def handle_in("started_typing", _, socket) do
    broadcast_from(socket, "started_typing", %{sender: socket.assigns.user.username})

    {:noreply, socket}
  end

  def handle_in("stopped_typing", _, socket) do
    broadcast_from(socket, "stopped_typing", %{sender: socket.assigns.user.username})

    {:noreply, socket}
  end
end
