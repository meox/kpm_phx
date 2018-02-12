defmodule HelloWeb.TicketChannel do
  use Phoenix.Channel
  require Logger

  alias CEM.GenTicket


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

  def handle_in("ticket_def", %{"ticket_type" => _ticket_type}, socket) do
    mapping = FakeTicket.load_mapper("./data/types_3219.json")
    {:reply, {:ok, %{ data: mapping }}, socket}
  end

  def handle_in("cem_fastsearch", req, socket) do
    {:ok, job_id, schema} = GenTicket.fast_search(cem_message(req), fn job_id, ticket -> 
      push socket, "ticket", %{ data: ticket, job_id: job_id }
    end)

    {:reply, {:ok, %{ job_id: job_id, schema: schema }}, socket}
  end


  ############## PRIVATE ##############


  defp handle_quidmaster(socket, quid_master, batch_size \\ 1) do
    Logger.info("request quid_master: #{quid_master}, batch_size: #{batch_size}")
    mapping = FakeTicket.load_mapper("./data/types_3219.json")

    Task.start_link(fn ->
          FakeTicket.start_sending(
            "./data/tickets_3219.csv",
            fn line ->
              tks = FakeTicket.convert(line, mapping)
              push socket, "ticket", %{ data: tks, tkt_type: 3219 }
          end)
      end)
  end

  defp cem_message(req) do
    {:ok, hostname} = :inet.gethostname()

    Poison.encode!(%{
      "action" => "fast_search",
      "hostname" => hostname |> to_string,
      "hot_expression" => Map.get(req, "hot_expression"),
      "from" => Map.get(req, "from"),
      "to" => Map.get(req, "to"),
      "preset" => Map.get(req, "preset", "cem_landing"),
      "n_item" => Map.get(req, "n_item", 100)
    })
  end

end
