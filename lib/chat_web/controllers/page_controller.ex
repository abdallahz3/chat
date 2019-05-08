defmodule ChatWeb.PageController do
  use ChatWeb, :controller
  alias Chat.Repo
  alias Chat.GroupMember
  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
