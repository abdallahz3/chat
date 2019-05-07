defmodule ChatWeb.GroupController do
  use ChatWeb, :controller
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
    res = from(g in Chat.GroupMember,
      where: g.member_id == ^params["username"],
      select: g.group_name
    )
    |> Chat.Repo.all

    json(conn, res)
  end
end
