defmodule ChatWeb.AdminController do
  use ChatWeb, :controller
  alias Chat.Repo
  import Ecto.Query, only: [from: 2]

  plug ChatWeb.Plugs.RequireAdmin when action not in [:login]

  def login(conn, param) do
    conn = fetch_session(conn)

    case authenticate(param["username"], param["token"]) do
      {:ok, user} ->
        conn
        |> put_session(:admin_username, "toz")
        |> configure_session(renew: true)
        |> json(%{loggedin: "success"})

      {:error, _} ->
        conn
        |> json(%{loggedin: "failed"})
    end
  end

  def create_group(conn, param) do
    IO.inspect(param)

    if Map.has_key?(param, "group_name") do
      Repo.insert(%Chat.Group{
        admin: conn.assigns.admin_username,
        group_name: param["group_name"]
      })

      json(conn, %{error: "", created: true})
    else
      json(conn, %{error: "You have to supply group_name", created: false})
    end
  end

  def get_groups(conn, param) do
    f =
      if Map.has_key?(param, "from") do
        param["from"]
      else
        1
      end

    t =
      if Map.has_key?(param, "to") do
        param["to"]
      else
        51
      end

    IO.puts("f: #{f}, t: #{t}")

    query =
      from g in Chat.Group,
        where: g.id >= ^f and g.id < ^t and g.admin == ^conn.assigns.admin_username,
        select: g

    groups =
      query |> Chat.Repo.all() |> Enum.map(fn g -> %{id: g.id, group_name: g.group_name} end)

    json(conn, groups)
  end

  def delete_group(conn, param) do
    if Map.has_key?(param, "group_name") do
      case Repo.get(Chat.Group, param["group_name"]) do
        nil ->
          json(conn, %{error: "Group does not exist"})

        group ->
          if group.admin == conn.assigns.admin_username do
            Repo.delete(group)
            json(conn, %{error: "", deleted: true})
          else
            json(conn, %{error: "It is not your group", deleted: false})
          end
      end
    else
      if Map.has_key?(param, "group_name") do
      else
        json(conn, %{error: "You need to specify either group_name"})
      end
    end
  end

  def add_member_to_group(conn, param) do
    if !Map.has_key?(param, "group_name") do
      json(conn, %{error: "You need to specify group_name"})
    else
      if !Map.has_key?(param, "member_id") do
        json(conn, %{error: "You need to specify member_id"})
      else
        case Repo.get(Chat.Group, param["group_name"]) do
          nil ->
            json(conn, %{error: "Group does not exist"})

          group ->
            if group.admin != conn.assigns.admin_usrname do
              json(conn, %{error: "Not your group"})
            else
              case from(g in Chat.GroupMember,
                     where: g.group_name == ^group.group_name and g.member_id == ^param["member_id"],
                     select: g
                   )
                   |> Chat.Repo.all() do
                [] ->
                  Repo.insert(%Chat.GroupMember{
                    # member_id: Integer.to_string(param["member_id"]),
                    # member_id: param["member_id"],
                    group_name: param["group_name"]
                  })

                  json(conn, %{error: "", added: true})

                [_member] ->
                  json(conn, %{error: "Already member"})
              end
            end
        end
      end
    end
  end

  def get_group_members(conn, param) do
    if !Map.has_key?(param, "group_name") do
      json(conn, %{error: "You need to specify group_name"})
    else
      group = Chat.Repo.get(Chat.Group, param["group_name"])
      if group.admin != conn.assigns.admin_username do
        json(conn, %{error: "Not your group"})
      else
        group = Chat.Repo.preload(group, [:members])

        members =
          group
          |> (fn g -> g.members end).()
          |> Enum.map(fn m -> m.member_id end)

        json(conn, members)
      end
    end
  end

  def authenticate(username, token) do
    {:ok, "toz"}
  end
end
