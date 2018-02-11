defmodule CEM.TicketState do
  defstruct socket: nil,
            chumak_pid: nil,
            ip: "127.0.0.1",
            port: 1789,
            job_map: %{}
end
