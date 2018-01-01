defmodule HelloWeb.TicketChannel do
  use Phoenix.Channel
  require Logger

  def join("tickets:lobby", _auth_message, socket) do
    Logger.info("new connection")
    {:ok, socket}
  end

  def handle_in("quid_master", %{"quid_master" => quid_master}, socket) do
    handle_quidmaster(socket, quid_master)
    {:noreply, socket}
  end
  
  def handle_in("quid_master", %{"quid_master" => quid_master, "batch_size" => batch_size}, socket) do
    handle_quidmaster(socket, quid_master, batch_size)
    {:noreply, socket}
  end

  def handle_in("ticket_def", %{"ticket_type" => ticket_type}, socket) do
    mapping = FakeTicket.load_mapper("./data/types_3219.json")
    {:reply, {:ok, %{ data: mapping }}, socket}
  end

  defp handle_quidmaster(socket, quid_master, batch_size \\ 1) do
    Logger.info("request quid_master: #{quid_master}, batch_size: #{batch_size}")
    mapping = FakeTicket.load_mapper("./data/types_3219.json")

    Task.start_link(fn ->
          FakeTicket.start_sending(
            "./data/tickets_3219.csv",
            fn line ->
              tks = FakeTicket.convert(line, mapping)
              push socket, "ticket", %{ data: tks }
          end)
      end)

  end

end
