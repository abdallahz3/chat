defmodule ChatWeb.UserController do
  use ChatWeb, :controller
  alias Chat.Repo
  import Ecto.Query, only: [from: 2]

  def initialize_new_group(conn, _params) do
    s =
      :crypto.strong_rand_bytes(10) |> Base.encode32() |> binary_part(0, 10) |> String.downcase()

    # TODO: get salt from config
    t = Phoenix.Token.sign(ChatWeb.Endpoint, "salt", s)

    json(conn, %{chat_group_name: s, token: t})
  end

  def get_groups(conn, params) do
    # {:ok, res} = Ecto.Adapters.SQL.query Chat.Repo, "select * from groups_members where member_id = 'avsnalawade123@gmail.com'", []
    res =
      from(g in Chat.GroupMember,
        where: g.member_id == ^params["username"],
        select: g.group_name
      )
      |> Chat.Repo.all()

    json(conn, res)
  end

  def create_peer_to_peer_group(conn, params) do
    my_username = conn.assigns.user.username
    his_username = params["with"]

    peer_to_peer_group_name =
      get_peer_to_peer_group_name_from_usernames(my_username, his_username)

    ch = check_already_have_peer_group(peer_to_peer_group_name)

    if ch do
      json(conn, %{error: "one to one chat already exist", created: false})
    else
      Repo.insert(%Chat.Group{
        admin: "",
        group_name: peer_to_peer_group_name
      })

      Repo.insert(%Chat.GroupMember{
        member_id: my_username,
        group_name: peer_to_peer_group_name
      })

      Repo.insert(%Chat.GroupMember{
        member_id: his_username,
        group_name: peer_to_peer_group_name
      })

      json(conn, %{error: "", created: true, group_name: peer_to_peer_group_name})
    end
  end

  def get_previous_messages_of_group(conn, params) do
    if !Map.has_key? params, "group_name" do
      json(conn, %{error: "you need to supply an group name"})
    else
      if Map.has_key? params, "last" do
        from(m in Chat.GroupMessage, where: m.group_name == ^params["group_name"], order_by: [desc: m.id], limit: 10) |> Repo.all()
      else
        # res = from(m in Chat.GroupMessage, where: m.group_name == ^params["group_name"], order_by: [desc: m.id], limit: 10) |> Repo.all()

	{:ok, res} = Ecto.Adapters.SQL.query Chat.Repo, "select * from (select * from groups_messages as gm2 order by gm2.id desc limit 10) as gm1 order by id;", []


        case res do
          [] -> json(conn, %{error: "no messages yet"})
          messages ->
            # messages = Enum.map messages.rows, fn m -> %{group_name: m.group_name, member_id: m.member_id, message: m.message} end
            messages = Enum.map messages.rows, fn m ->
              [_, group_name, member_id, message, _, _] = m
              %{group_name: group_name, member_id: member_id, message: message}
            end
            json(conn, %{error: "", messages: messages})
        end
      end
    end
  end

  defp check_already_have_peer_group(group_name) do
    group =
      from(g in Chat.Group, where: g.group_name == ^group_name, select: g) |> Chat.Repo.all()

    case group do
      [] -> false
      group -> true
    end
  end

  defp get_peer_to_peer_group_name_from_usernames(u1, u2) do
    if u1 > u2 do
      "#{u1}|#{u2}"
    else
      "#{u2}|#{u1}"
    end
  end
end
