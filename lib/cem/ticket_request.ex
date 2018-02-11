defmodule CEM.TTReq do

  def send_fastsearch(socket, msg) do
    :chumak.send(socket, [
      msg |> to_charlist
    ])

    get_response(socket)
  end


  def take_tickets(socket, job_id) do
    msg = Poison.encode!(%{
      "action" => "take_ticket",
      "job_id" => job_id
    })

    :chumak.send(socket, [
      msg |> to_charlist
    ])

    case get_response(socket) do
      {:ok, reply_msg} ->
        process_take_tickets(reply_msg)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp process_take_tickets(%{"error" => false, "ntickets" => ntickets, "status" => status, "tickets" => tickets}) do
    IO.puts("retrived: #{ntickets} tickets")
    {:ok, tickets, is_finish(status)}
  end

  defp process_take_tickets(%{"error" => true, "value" => value}) do
    {:error, value}
  end

  defp get_response(socket) do
    case :chumak.recv(socket) do
      {:ok, msg} ->
        {:ok, msg |> to_string |> Poison.decode!()}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp is_finish(status) do
    status == "COMPLETED" || status == "ABORTED"
  end

  #### FAKE ####

  def sample_request() do
    {:ok, hostname} = :inet.gethostname()
    dt_now = now()

    Poison.encode!(%{
      "action" => "fast_search",
      "hostname" => hostname |> to_string,
      "hot_expression" => "imsi == 655079926087774",
      "from" => dt_now - 3600 * 24,
      "to" => dt_now - 10,
      "preset" => "cem_landing",
      "n_item" => 100
    })
  end

  defp now() do
    DateTime.utc_now() |> DateTime.to_unix()
  end

end
