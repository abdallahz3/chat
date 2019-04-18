defmodule ChatWeb.SupportAgentGroup do
  use ChatWeb, :channel

  def join("companies:" <> company, _params, socket) do
    if socket.assigns.is_support_agent do
      if socket.assigns.company == company do
        IO.puts("this is a company: " <> company)
        {:ok, socket}
      else
        {:error, %{reason: "Not your company"}}
      end
    else
      {:error, %{reason: "Not support agent"}}
    end
  end

  def handle_in("customer_needs_support_agent", msg, socket) do
    broadcast!(socket, "customer_needs_support_agent", %{
      message: msg
    })

    {:noreply, socket}
  end
end
