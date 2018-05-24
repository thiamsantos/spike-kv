defmodule Spike.ServerTest do
  use ExUnit.Case

  @moduletag :capture_log

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, opts)
    %{socket: socket}
  end

  test "server interaction", %{socket: socket} do
    assert send_and_recv(socket, "GET eggs\r\n") == "NOT FOUND\r\n"

    assert send_and_recv(socket, "SET eggs 3\r\n") == "OK\r\n"

    # GET returns two lines
    assert send_and_recv(socket, "GET eggs\r\n") == "3\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    assert send_and_recv(socket, "DEL eggs\r\n") == "OK\r\n"
    assert send_and_recv(socket, "GET eggs\r\n") == "NOT FOUND\r\n"
  end

  test "ping", %{socket: socket} do
    assert send_and_recv(socket, "PING\r\n") == "PONG\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    assert send_and_recv(socket, "PING hello world\r\n") == "hello world\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end
