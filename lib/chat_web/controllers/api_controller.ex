defmodule ChatWeb.ApiController do
  use ChatWeb, :controller
  import Ecto.Query, only: [from: 2]

  def initialize_new_group(conn, _params) do
    s =
      :crypto.strong_rand_bytes(10) |> Base.encode32() |> binary_part(0, 10) |> String.downcase()

    # TODO: get salt from config
    t = Phoenix.Token.sign(ChatWeb.Endpoint, "salt", s)

    json(conn, %{chat_group_name: s, token: t})
  end

  def sync(conn, params) do
    case params["delete"]["username"] do
      nil ->
        json(conn, %{error: "you need to specify username"})

      username ->
        from(u in GroupMember, where: u.member_id == ^username)
        |> Repo.delete_all()

        json(conn, %{error: "", deleted: true})
    end
  end

end
