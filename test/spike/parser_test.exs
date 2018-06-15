defmodule Spike.ParserTest do
  use ExUnit.Case, async: true

  alias Spike.{Parser, Command}

  describe "parse/1" do
    test "set commands" do
      actual = Parser.parse("SET key value\r\n")
      expected = {:ok, %Command{fun: :set, args: ["key", "value"]}}

      assert actual == expected
    end

    test "set command with expiration time" do
      actual = Parser.parse("SET key value 10\r\n")
      expected = {:ok, %Command{fun: :set, args: ["key", "value", 10]}}

      assert actual == expected
    end

    test "set command with invalid time" do
      actual = Parser.parse("SET key value invalid_time\r\n")
      expected = {:error, :unknown_command}

      assert actual == expected
    end

    test "get commands" do
      actual = Parser.parse("GET key\r\n")
      expected = {:ok, %Command{fun: :get, args: ["key"]}}

      assert actual == expected
    end

    test "lf line breaks" do
      actual = Parser.parse("GET key\n")
      expected = {:ok, %Command{fun: :get, args: ["key"]}}

      assert actual == expected
    end

    test "unknown command if missing arguments" do
      actual = Parser.parse("SET key\r\n")
      expected = {:error, :unknown_command}

      assert actual == expected
    end

    test "del commands" do
      actual = Parser.parse("DEL key\r\n")
      expected = {:ok, %Command{fun: :del, args: ["key"]}}

      assert actual == expected
    end

    test "ping commmand" do
      actual = Parser.parse("PING something\r\n")
      expected = {:ok, %Command{fun: :ping, args: ["something"]}}

      assert actual == expected
    end

    test "ping without arguments" do
      actual = Parser.parse("PING\r\n")
      expected = {:ok, %Command{fun: :ping, args: [""]}}

      assert actual == expected
    end

    test "ping with more than one argument" do
      actual = Parser.parse("PING hello world\r\n")
      expected = {:ok, %Command{fun: :ping, args: ["hello world"]}}

      assert actual == expected
    end

    test "exists command" do
      actual = Parser.parse("EXISTS hello\r\n")
      expected = {:ok, %Command{fun: :exists?, args: ["hello"]}}

      assert actual == expected
    end

    test "getset command" do
      actual = Parser.parse("GETSET key value\r\n")
      expected = {:ok, %Command{fun: :getset, args: ["key", "value"]}}

      assert actual == expected
    end

    test "getset command with expiration" do
      actual = Parser.parse("GETSET key value 15\r\n")
      expected = {:ok, %Command{fun: :getset, args: ["key", "value", 15]}}

      assert actual == expected
    end

    test "ttl command" do
      actual = Parser.parse("TTL key\r\n")
      expected = {:ok, %Command{fun: :ttl, args: ["key"]}}

      assert actual == expected
    end

    test "rename command" do
      actual = Parser.parse("RENAME oldkey newkey\r\n")
      expected = {:ok, %Command{fun: :rename, args: ["oldkey", "newkey"]}}

      assert actual == expected
    end
  end
end
