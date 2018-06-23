defmodule Spike.ParserTest do
  use ExUnit.Case, async: true

  alias Spike.Parser
  alias Spike.Command.{Get, Set, Del, Exists, Ping, Getset, Rename, Ttl, Error, Keys, Flush}

  describe "parse/1" do
    test "set commands" do
      actual = Parser.parse(["SET", "key", "value"])
      expected = %Set{key: "key", value: "value"}

      assert actual == expected
    end

    test "set command with exp time" do
      actual = Parser.parse(["SET", "key", "value", 10])
      expected = %Set{key: "key", value: "value", exp: 10}

      assert actual == expected
    end

    test "set command with invalid time" do
      actual = Parser.parse(["SET", "key", "value", "invalid_time"])
      expected = %Error{message: :unknown_command}

      assert actual == expected
    end

    test "get commands" do
      actual = Parser.parse(["GET", "key"])
      expected = %Get{key: "key"}

      assert actual == expected
    end

    test "unknown command if missing arguments" do
      actual = Parser.parse(["SET", "key"])
      expected = %Error{message: :unknown_command}

      assert actual == expected
    end

    test "del commands" do
      actual = Parser.parse(["DEL", "key"])
      expected = %Del{key: "key"}

      assert actual == expected
    end

    test "ping commmand" do
      actual = Parser.parse(["PING", "something"])
      expected = %Ping{message: "something"}

      assert actual == expected
    end

    test "ping without arguments" do
      actual = Parser.parse(["PING"])
      expected = %Ping{message: "PONG"}

      assert actual == expected
    end

    test "ping with more than one argument" do
      actual = Parser.parse(["PING", "hello world"])
      expected = %Ping{message: "hello world"}

      assert actual == expected
    end

    test "exists command" do
      actual = Parser.parse(["EXISTS", "hello"])
      expected = %Exists{key: "hello"}

      assert actual == expected
    end

    test "getset command" do
      actual = Parser.parse(["GETSET", "key", "value"])
      expected = %Getset{key: "key", value: "value"}

      assert actual == expected
    end

    test "getset command with exp" do
      actual = Parser.parse(["GETSET", "key", "value", 15])
      expected = %Getset{key: "key", value: "value", exp: 15}

      assert actual == expected
    end

    test "ttl command" do
      actual = Parser.parse(["TTL", "key"])
      expected = %Ttl{key: "key"}

      assert actual == expected
    end

    test "rename command" do
      actual = Parser.parse(["RENAME", "oldkey", "newkey"])
      expected = %Rename{oldkey: "oldkey", newkey: "newkey"}

      assert actual == expected
    end

    test "keys command" do
      actual = Parser.parse(["KEYS"])
      expected = %Keys{}

      assert actual == expected
    end

    test "flush command" do
      actual = Parser.parse(["FLUSH"])
      expected = %Flush{}

      assert actual == expected
    end
  end
end
