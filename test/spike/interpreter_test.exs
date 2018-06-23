defmodule Spike.InterpreterTest do
  use ExUnit.Case, async: true

  alias Spike.{Parser, Lexer}
  alias Spike.Command.{Get, Set, Del, Exists, Ping, Getset, Rename, Ttl, Error, Keys}

  describe "parse/1" do
    test "set commands" do
      actual = run("SET key value\r\n")
      expected = %Set{key: "key", value: "value"}

      assert actual == expected
    end

    test "set command with exp time" do
      actual = run("SET key value 10\r\n")
      expected = %Set{key: "key", value: "value", exp: 10}

      assert actual == expected
    end

    test "set command with invalid time" do
      actual = run("SET key value invalid_time\r\n")
      expected = %Error{message: :unknown_command}

      assert actual == expected
    end

    test "get commands" do
      actual = run("GET key\r\n")
      expected = %Get{key: "key"}

      assert actual == expected
    end

    test "lf line breaks" do
      actual = run("GET key\n")
      expected = %Get{key: "key"}

      assert actual == expected
    end

    test "unknown command if missing arguments" do
      actual = run("SET key\r\n")
      expected = %Error{message: :unknown_command}

      assert actual == expected
    end

    test "del commands" do
      actual = run("DEL key\r\n")
      expected = %Del{key: "key"}

      assert actual == expected
    end

    test "ping commmand" do
      actual = run("PING something\r\n")
      expected = %Ping{message: "something"}

      assert actual == expected
    end

    test "ping without arguments" do
      actual = run("PING\r\n")
      expected = %Ping{message: "PONG"}

      assert actual == expected
    end

    test "ping with more than one argument" do
      actual = run(~s(PING "hello world"\r\n))
      expected = %Ping{message: "hello world"}

      assert actual == expected
    end

    test "exists command" do
      actual = run("EXISTS hello\r\n")
      expected = %Exists{key: "hello"}

      assert actual == expected
    end

    test "getset command" do
      actual = run("GETSET key value\r\n")
      expected = %Getset{key: "key", value: "value"}

      assert actual == expected
    end

    test "getset command with exp" do
      actual = run("GETSET key value 15\r\n")
      expected = %Getset{key: "key", value: "value", exp: 15}

      assert actual == expected
    end

    test "ttl command" do
      actual = run("TTL key\r\n")
      expected = %Ttl{key: "key"}

      assert actual == expected
    end

    test "rename command" do
      actual = run("RENAME oldkey newkey\r\n")
      expected = %Rename{oldkey: "oldkey", newkey: "newkey"}

      assert actual == expected
    end

    test "keys command" do
      actual = run("KEYS\r\n")
      expected = %Keys{}

      assert actual == expected
    end
  end

  defp run(command) do
    command
    |> Lexer.run()
    |> Parser.parse()
  end
end
