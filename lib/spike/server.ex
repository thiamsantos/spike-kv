defmodule Spike.Server do
  alias Spike.{Command, Client}

  def serve(socket) do
    socket
    |> read_line()
    |> Command.parse()
    |> Client.run()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
