defmodule CEM.GenTicket do
  use GenServer
  require OK

  alias CEM.{TTReq, TicketState}

  def start_link(state = %TicketState{}) do
    GenServer.start_link(__MODULE__, state)
  end

  def fast_search(pid, msg \\ TTReq.sample_request()) do
    GenServer.call(pid, {:fast_search, msg})
  end

  def init(state = %TicketState{}) do
    {:ok, socket} = :chumak.socket(:req, "id_#{state.ip}_#{state.port}" |> to_charlist)
    {:ok, %{ state | socket: socket }}
  end


  # Callbacks

  def handle_call({:fast_search, msg}, _from, state) do
    {_, reply} = OK.for do
      chumak_pid <- ticket2zmq_connect(state)
      response <- TTReq.send_fastsearch(state.socket, msg)
    after
      process_fast_search(chumak_pid, response, state)
    end

    reply
  end

  def handle_info({:take_ticket, job_id}, state) do
    case TTReq.take_tickets(state.socket, job_id) do
      {:ok, tickets, false} ->
        # we have other tickets to take
        Process.send_after(self(), {:take_ticket, job_id}, 1000)
        {:noreply, %{ state | job_map: update_ticket(state, job_id, tickets) }}

      {:ok, tickets, true} ->
        # no more tickets
        {:noreply, %{ state | job_map: update_ticket(state, job_id, tickets) }}

      {:error, error_msg} ->
        IO.puts("Error: #{error_msg}")
        {:noreply, state}
    end
  end


  #### INTERNAL #####

  defp update_ticket(state, job_id, tickets) do
    job = state.job_map |> Map.get(job_id)
    state.job_map
    |> Map.put(job_id, %{schema: job.schema, tickets: List.flatten([job.ticket | tickets])})
  end

  defp ticket2zmq_connect(state = %TicketState{chumak_pid: nil}) do
    :chumak.connect(state.socket, :tcp, state.ip |> to_charlist, state.port)
  end

  defp ticket2zmq_connect(state = %TicketState{}) do
    {:ok, state.chumak_pid}
  end


  defp process_fast_search(chumak_pid, response, state) do
    case response do
      %{"error" => false, "job_id" => job_id, "schema" => schema} ->
        new_job_map = Map.put(state.job_map, job_id, %{schema: schema, tickets: []})
        state = %{ state | chumak_pid: chumak_pid, job_map: new_job_map }
        Process.send_after(self(), {:take_ticket, job_id}, 1000)
        {:reply, {:ok, job_id}, state}
  
      %{"error" => true, "value" => value} ->
        {:reply, {:error, value}, state}
  
      _ ->
        {:reply, {:error, "generic error"}, state}
    end
  end

end
