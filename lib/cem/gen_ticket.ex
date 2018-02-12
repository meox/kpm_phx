defmodule CEM.GenTicket do
  use GenServer
  require OK

  alias CEM.{TTReq, TicketState}

  def start_link(state = %TicketState{}) do
    GenServer.start_link(__MODULE__, state, name: :cem_gen_ticket)
  end

  def fast_search(msg, phx_callback) do
    GenServer.call(:cem_gen_ticket, {:fast_search, msg, phx_callback})
  end

  def init(state = %TicketState{}) do
    {:ok, socket} = :chumak.socket(:req, "id_#{state.ip}_#{state.port}" |> to_charlist)
    {:ok, %{ state | socket: socket }}
  end


  # Callbacks

  def handle_call({:fast_search, msg, phx_callback}, _from, state) do
    {_, reply} = OK.for do
      chumak_pid <- ticket2zmq_connect(state)
      response <- TTReq.send_fastsearch(state.socket, msg)
    after
      process_fast_search(chumak_pid, response, state, phx_callback)
    end

    reply
  end

  def handle_info({:take_ticket, job_id, phx_callback}, state) do
    case TTReq.take_tickets(state.socket, job_id) do
      {:ok, tickets, false} ->
        # we have other tickets to take
        phx_callback.(job_id, tickets)
        Process.send_after(self(), {:take_ticket, job_id, phx_callback}, 1000)
        {:noreply, state}

      {:ok, tickets, true} ->
        # no more tickets
        phx_callback.(job_id, tickets)

        #todo: remove schema
        {:noreply, state}

      {:error, error_msg} ->
        IO.puts("Error: #{error_msg}")
        {:noreply, state}
    end
  end


  #### INTERNAL #####

  defp ticket2zmq_connect(state = %TicketState{chumak_pid: nil}) do
    :chumak.connect(state.socket, :tcp, state.ip |> to_charlist, state.port)
  end

  defp ticket2zmq_connect(state = %TicketState{}) do
    {:ok, state.chumak_pid}
  end

  defp process_fast_search(chumak_pid, response, state, phx_callback) do
    case response do
      %{"error" => false, "job_id" => job_id, "schema" => schema} ->
        Process.send_after(self(), {:take_ticket, job_id, phx_callback}, 1000)
        {:reply, {:ok, job_id, schema}, %{ state | chumak_pid: chumak_pid }}
  
      %{"error" => true, "value" => value} ->
        {:reply, {:error, value}, %{ state | chumak_pid: chumak_pid }}
  
      _ ->
        {:reply, {:error, "generic error"}, %{ state | chumak_pid: chumak_pid }}
    end
  end

end
