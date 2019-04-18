defmodule ChatWeb.GroupChatState do
  use Agent

  def start_link(name) do
    Agent.start_link(fn -> %{} end, name: via_tuple(name))
  end

  def via_tuple(group_chat_name) do
    {:via, Registry, {SupportChat.GroupChatsRegistry, group_chat_name}}
  end

  def group_chat_state_agent_pid(name) do
    name
    |> via_tuple()
    |> GenServer.whereis()
  end
end
