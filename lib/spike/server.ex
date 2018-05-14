defmodule Spike.Server do
  use Task, restart: :permanent

  alias :gen_tcp, as: GenTCP

  require Logger
  alias Spike.Command

  def start_link(_) do
    Task.start_link(__MODULE__, :accept, [4040])
  end

  def accept(port) do
    {:ok, socket} =
      GenTCP.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = GenTCP.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Spike.TaskSupervisor, fn -> serve(client) end)
    :ok = GenTCP.controlling_process(client, pid)

    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> Command.parse()
    |> Command.run()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = GenTCP.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    GenTCP.send(socket, line)
  end
end
