defmodule ChatWeb.Group do
  use ChatWeb, :channel
  alias Chat.Repo
  import Ecto.Query, only: [from: 2]

  def join("groups:" <> group_name, _params, socket) do
    case Repo.get_by(Chat.Group, group_name: group_name) do
      nil ->
        {:error, %{reason: "Group does not exist"}}

      group ->
        case from(g in Chat.GroupMember,
               where: g.group_id == ^group.id and g.member_id == ^socket.assigns.username,
               select: g
             )
             |> Chat.Repo.all() do
          [] ->
            {:error, %{reason: "You are not in the Group"}}

          [_member] ->
            IO.puts("member #{socket.assigns.username} joined")
            {:ok, socket}
        end
    end
  end

  def handle_in("new_chat_message", %{"message" => message}, socket) do
    IO.puts(message)

    broadcast!(socket, "new_chat_message", %{
      message: message,
      sender: socket.assigns.username
    })

    {:noreply, socket}
  end
end
