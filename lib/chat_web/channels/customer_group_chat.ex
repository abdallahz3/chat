defmodule ChatWeb.CustomerGroup do
  use ChatWeb, :channel
  alias Chat.Repo
  alias Chat.CustomerMessage

  def join("customers_groups:" <> customer_group_name, _params, socket) do
    if Map.has_key?(socket.assigns.user, :is_customer) && socket.assigns.user.is_customer == true  do
      if socket.assigns.user.customer_group_name != customer_group_name do
        {:error, %{reason: "Not your chat group"}}
      else
        {:ok, socket}
      end
    else
      # TODO: should check for only support agents
      {:ok, socket}
    end
  end

  def handle_in("new_chat_message", %{"message" => message}, socket) do
    "customers_groups:" <> topic = socket.topic

    if Map.has_key?(socket.assigns.user, :is_customer) && socket.assigns.user.is_customer == false do
    # if !socket.assigns.user.is_customer do
      Repo.insert(%CustomerMessage{
        group_name: topic,
        company_id: socket.assigns.user.company,
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
        company_id: socket.assigns.user.company,
        message: message,
        sent_by: "customer"
      })

      broadcast!(socket, "new_chat_message", %{
        message: message,
        sender: socket.assigns.user.name || "customer"
      })
    end

    {:noreply, socket}
  end

  def handle_in("new_name", %{"name" => name}, socket) do

    if Map.has_key?(socket.assigns.user, :is_customer) && socket.assigns.user.is_customer == true do
    # if socket.assigns.user.is_customer do
      socket = assign(socket, :name, name)
      socket = put_in(socket, [:assigns, :user, :name], name)
      broadcast_from(socket, "new_name", %{sender: "customer", name: name})
    end

    {:noreply, socket}
  end

  def handle_in("started_typing", _, socket) do

    if Map.has_key?(socket.assigns.user, :is_customer) && socket.assigns.user.is_customer == false do
    # if !socket.assigns.user.is_customer do
      broadcast_from(socket, "started_typing", %{sender: "support_agent"})
    else
      broadcast_from(socket, "started_typing", %{sender: "customer"})
    end

    {:noreply, socket}
  end

  def handle_in("stopped_typing", _, socket) do

    if Map.has_key?(socket.assigns.user, :is_customer) && socket.assigns.user.is_customer == false do
    # if !socket.assigns.user.is_customer do
      broadcast_from(socket, "stopped_typing", %{sender: "support_agent"})
    else
      broadcast_from(socket, "stopped_typing", %{sender: "customer"})
    end

    {:noreply, socket}
  end

  def handle_in("customer_needs_support_agent", _msg, socket) do
    ChatWeb.Endpoint.broadcast_from!(
      self(),
      "companies:" <> socket.assigns.user.company,
      "customer_needs_support_agent",
      %{customer_chat_group: socket.topic}
    )

    {:noreply, socket}
  end
end
