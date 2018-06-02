defmodule Spike.SocketTest do
  use ExUnit.Case, async: true

  @moduletag :capture_log

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, opts)
    %{socket: socket}
  end

  test "server interaction", %{socket: socket} do
    assert send_and_recv(socket, "GET eggs\r\n") == ":OK $0\r\n"

    assert send_and_recv(socket, "SET eggs 3\r\n") == ":OK\r\n"

    assert send_and_recv(socket, "GET eggs\r\n") == ":OK $1 3\r\n"

    assert send_and_recv(socket, "DEL eggs\r\n") == ":OK\r\n"
    assert send_and_recv(socket, "GET eggs\r\n") == ":OK $0\r\n"
  end

  test "ping", %{socket: socket} do
    assert send_and_recv(socket, "PING\r\n") == ":OK $4 PONG\r\n"
    assert send_and_recv(socket, "PING hello world\r\n") == ":OK $11 hello world\r\n"
  end

  test "exists", %{socket: socket} do
    assert send_and_recv(socket, "SET eggs 3\r\n") == ":OK\r\n"

    assert send_and_recv(socket, "EXISTS eggs\r\n") == ":OK +1\r\n"

    assert send_and_recv(socket, "DEL eggs\r\n") == ":OK\r\n"

    assert send_and_recv(socket, "EXISTS eggs\r\n") == ":OK +0\r\n"
  end

  test "unknown command", %{socket: socket} do
    assert send_and_recv(socket, "SET key\r\n") == ":ERROR :UNKNOWN_COMMAND\r\n"
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end
