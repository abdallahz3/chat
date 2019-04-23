defmodule ChatWeb.CustomerGroup do
  use ChatWeb, :channel
  alias Chat.Repo
  alias Chat.CustomerMessage

  def join("customers_groups:" <> chat_group_name, _params, socket) do
    # case ChatWeb.GroupChatState.group_chat_state_agent_pid chat_group_name do
    #   pid when is_pid(pid) ->
    #     nil ->
    #       #create in database
    # end
    # if support agent allow him to join
    IO.inspect(socket)

    if socket.assigns.is_support_agent do
      {:ok, socket}
    else
      if socket.assigns.chat_group_name == chat_group_name do
        # socket = %{socket | topic: "customers_groups:toz"}
        {:ok, socket}
      else
        {:error, %{reason: "Not your chat group"}}
      end
    end
  end

  def handle_in("new_chat_message", %{"message" => message}, socket) do
    "customers_groups:" <> topic = socket.topic

    if socket.assigns.is_support_agent do
      Repo.insert(%CustomerMessage{
        group_name: topic,
        company_id: socket.assigns.company,
        message: message,
        sent_by: "support_agent"
      })

      broadcast!(socket, "new_chat_message", %{
        message: message,
        sender: "support_agent"
      })
    else
      Repo.insert(%CustomerMessage{
        group_name: topic,
        company_id: socket.assigns.company,
        message: message,
        sent_by: "customer"
      })

      broadcast!(socket, "new_chat_message", %{
        message: message,
        sender: socket.assigns[:name] || "customer"
      })
    end

    {:noreply, socket}
  end

  def handle_in("new_name", %{"name" => name}, socket) do
    if socket.assigns.is_support_agent do
      # nothing
    else
      socket = assign(socket, :name, name)
      broadcast_from(socket, "new_name", %{sender: "customer", name: name})
    end

    {:noreply, socket}
  end

  def handle_in("started_typing", _, socket) do
    if socket.assigns.is_support_agent do
      broadcast_from(socket, "started_typing", %{sender: "support_agent"})
    else
      broadcast_from(socket, "started_typing", %{sender: "customer"})
    end

    {:noreply, socket}
  end

  def handle_in("stopped_typing", _, socket) do
    if socket.assigns.is_support_agent do
      broadcast_from(socket, "stopped_typing", %{sender: "support_agent"})
    else
      broadcast_from(socket, "stopped_typing", %{sender: "customer"})
    end

    {:noreply, socket}
  end

  def handle_in("customer_needs_support_agent", _msg, socket) do
    ChatWeb.Endpoint.broadcast_from!(
      self(),
      "companies:" <> socket.assigns.company,
      "customer_needs_support_agent",
      %{customer_chat_group: socket.topic}
    )

    {:noreply, socket}
  end
end
