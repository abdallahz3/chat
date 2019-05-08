defmodule ChatWeb.AdminController do
  use ChatWeb, :controller
  alias Chat.Repo
  import Ecto.Query, only: [from: 2]

  def create_group(conn, param) do
    if Map.has_key?(param, "group_name") do
      Repo.insert(%Chat.Group{
        admin: conn.assigns.user.username,
        group_name: param["group_name"]
      })

      if Map.has_key?(param, "join_me") do
        if param["join_me"] == true do
          Repo.insert(%Chat.GroupMember{
            member_id: conn.assigns.user.username,
            group_name: param["group_name"]
          })
        end
      end

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
        where: g.id >= ^f and g.id < ^t and g.admin == ^conn.assigns.user.username,
        select: g

    groups =
      query |> Chat.Repo.all() |> Enum.map(fn g -> %{id: g.id, group_name: g.group_name} end)

    json(conn, groups)
  end

  def delete_group(conn, param) do
    if Map.has_key?(param, "group_name") do
      case Repo.get_by(Chat.Group, group_name: param["group_name"]) do
        nil ->
          json(conn, %{error: "Group does not exist"})

        group ->
          if group.admin == conn.assigns.user.username do
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
      if !Map.has_key?(param, "members_ids") do
        json(conn, %{error: "You need to specify members_ids"})
      else
        case Repo.get_by(Chat.Group, group_name: param["group_name"]) do
          nil ->
            json(conn, %{error: "Group does not exist"})

          group ->
            if group.admin != conn.assigns.user.username do
              json(conn, %{error: "Not your group"})
            else
              res =
                Enum.map(param["members_ids"], fn member_id ->
                  case from(g in Chat.GroupMember,
                         where:
                           g.group_name == ^param["group_name"] and
                             g.member_id == ^member_id,
                         select: g
                       )
                       |> Chat.Repo.all() do
                    [] ->
                      Repo.insert(%Chat.GroupMember{
                        # member_id: Integer.to_string(param["member_id"]),
                        member_id: member_id,
                        group_name: param["group_name"]
                      })

                      %{member_id: member_id, error: "", added: true}

                    [_member] ->
                      %{member_id: member_id, error: "Already member"}
                  end
                end)

              json(conn, res)
            end
        end
      end
    end
  end

  def delete_member_from_group(conn, param) do
    if !Map.has_key?(param, "group_name") do
      json(conn, %{error: "You need to specify group_name"})
    else
      if !Map.has_key?(param, "members_ids") do
        json(conn, %{error: "You need to specify members_ids"})
      else
        case Repo.get_by(Chat.Group, group_name: param["group_name"]) do
          nil ->
            json(conn, %{error: "Group does not exist"})

          group ->
            if group.admin != conn.assigns.user.username do
              json(conn, %{error: "Not your group"})
            else
              res =
                Enum.map(param["members_ids"], fn member_id ->
                  case from(g in Chat.GroupMember,
                         where:
                           g.group_name == ^param["group_name"] and
                             g.member_id == ^member_id,
                         select: g
                       )
                       |> Chat.Repo.all() do
                    [] ->
                      %{member_id: member_id, error: "member not found in group"}

                    [member] ->
                      Repo.delete(member)
                      %{member_id: member_id, error: "", deleted: true}
                  end
                end)

              json(conn, res)
            end
        end
      end
    end
  end

  def get_group_members(conn, param) do
    if !Map.has_key?(param, "group_name") do
      json(conn, %{error: "You need to specify group_name"})
    else
      group = Chat.Repo.get_by(Chat.Group, group_name: param["group_name"])

      case group do
        nil ->
          json(conn, %{error: "Group does not exist"})

        group ->
          if group.admin != conn.assigns.user.username do
            json(conn, %{error: "Not your group"})
          else
            # group = Chat.Repo.preload(group, [:members])
            # members = from m in Chat.GroupMember,
            #   where: m.group_name == ^param["group_name"],
            #   select: m
            #   |> Chat.Repo.all()

            q =
              from m in Chat.GroupMember,
                where: m.group_name == ^param["group_name"],
                select: m

            members = Chat.Repo.all(q)

            members = members |> Enum.map(fn m -> m.member_id end)

            json(conn, members)
          end
      end
    end
  end
end
