defmodule ChatWeb.PageController do
  use ChatWeb, :controller
  alias Chat.Repo
  alias Chat.GroupMember
  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    render(conn, "index.html")
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
