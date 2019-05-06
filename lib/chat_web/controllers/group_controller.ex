defmodule ChatWeb.GroupController do
  use ChatWeb, :controller

  def initialize_new_group(conn, _params) do
    s =
      :crypto.strong_rand_bytes(10) |> Base.encode32() |> binary_part(0, 10) |> String.downcase()

    # TODO: get salt from config
    t = Phoenix.Token.sign(ChatWeb.Endpoint, "salt", s)

    json(conn, %{chat_group_name: s, token: t})
  end

  def get_groups(conn, params) do
    IO.inspect params
    json(conn, %{toz: "toz"})
  end
end
