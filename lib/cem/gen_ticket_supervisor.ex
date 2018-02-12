defmodule CEM.GenTicket.Supervisor do
    use Supervisor
    alias CEM.{GenTicket, TicketState}

    def start_link(arg) do
        Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
    end

    def init(_args) do
        children = [
            {GenTicket, %TicketState{}}
        ]

        Supervisor.init(children, strategy: :one_for_one)
    end
end