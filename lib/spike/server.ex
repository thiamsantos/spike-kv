defmodule Spike.Server do
  require Logger
  alias Spike.{Command, Runner, ServerSupervisor}

  def serve(socket) do
    Logger.info("Starting connection with PID #{inspect(self())}")

    socket
    |> read_line()
    |> Command.parse()
    |> Runner.run()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    socket
    |> :gen_tcp.recv(0)
    |> handle_data_received()
  end

  defp handle_data_received({:ok, data}), do: data

  defp handle_data_received({:error, :closed}) do
    Logger.info("Closing connection with PID #{inspect(self())}")

    :ok = Task.Supervisor.terminate_child(ServerSupervisor, self())
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
