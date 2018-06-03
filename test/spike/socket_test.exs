defmodule Spike.SocketTest do
  use ExUnit.Case, async: true

  import Mox
  alias Spike.CurrentTimeMock

  @moduletag :capture_log

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, opts)
    %{socket: socket}
  end

  setup :set_mox_global
  setup :verify_on_exit!

  test "server interaction", %{socket: socket} do
    stub(CurrentTimeMock, :get_timestamp, fn -> 1 end)

    assert send_and_recv(socket, "GET eggs\r\n") == ":OK $0\r\n"
    assert send_and_recv(socket, "SET eggs 3\r\n") == ":OK\r\n"
    assert send_and_recv(socket, "GET eggs\r\n") == ":OK $1 3\r\n"
    assert send_and_recv(socket, "DEL eggs\r\n") == ":OK\r\n"
    assert send_and_recv(socket, "GET eggs\r\n") == ":OK $0\r\n"
  end

  test "server interaction with expiration", %{socket: socket} do
    expect(CurrentTimeMock, :get_timestamp, fn -> 1 end)
    assert send_and_recv(socket, "GET eggs\r\n") == ":OK $0\r\n"

    expect(CurrentTimeMock, :get_timestamp, fn -> 1 end)
    assert send_and_recv(socket, "SET eggs 3 10\r\n") == ":OK\r\n"

    expect(CurrentTimeMock, :get_timestamp, fn -> 10 end)
    assert send_and_recv(socket, "GET eggs\r\n") == ":OK $1 3\r\n"

    expect(CurrentTimeMock, :get_timestamp, fn -> 11 end)
    assert send_and_recv(socket, "GET eggs\r\n") == ":OK $0\r\n"
  end

  test "ping", %{socket: socket} do
    stub(Spike.CurrentTimeMock, :get_timestamp, fn -> 1 end)

    assert send_and_recv(socket, "PING\r\n") == ":OK $4 PONG\r\n"
    assert send_and_recv(socket, "PING hello world\r\n") == ":OK $11 hello world\r\n"
  end

  test "exists", %{socket: socket} do
    stub(CurrentTimeMock, :get_timestamp, fn -> 1 end)

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
