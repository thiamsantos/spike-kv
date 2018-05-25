defmodule Spike.Socket do
  use Task, restart: :permanent

  require Logger
  alias Spike.{ServerSupervisor, Server}

  def start_link(_) do
    Task.start_link(__MODULE__, :accept, [4040])
  end

  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(ServerSupervisor, Server, :serve, [client])
    :ok = :gen_tcp.controlling_process(client, pid)

    loop_acceptor(socket)
  end
end
