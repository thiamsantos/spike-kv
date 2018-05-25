defmodule Spike.CommandTest do
  use ExUnit.Case, async: true

  alias Spike.Command

  describe "parse/1" do
    test "set commands" do
      actual = Command.parse("SET key value\r\n")
      expected = {:ok, %Command{fun: :set, args: ["key", "value"]}}

      assert actual == expected
    end

    test "get commands" do
      actual = Command.parse("GET key\r\n")
      expected = {:ok, %Command{fun: :get, args: ["key"]}}

      assert actual == expected
    end

    test "lf line breaks" do
      actual = Command.parse("GET key\n")
      expected = {:ok, %Command{fun: :get, args: ["key"]}}

      assert actual == expected
    end

    test "unknown command if missing arguments" do
      actual = Command.parse("SET key\r\n")
      expected = {:error, :unknown_command}

      assert actual == expected
    end

    test "del commands" do
      actual = Command.parse("DEL key\r\n")
      expected = {:ok, %Command{fun: :del, args: ["key"]}}

      assert actual == expected
    end

    test "ping commmand" do
      actual = Command.parse("PING something\r\n")
      expected = {:ok, %Command{fun: :ping, args: ["something"]}}

      assert actual == expected
    end

    test "ping without arguments" do
      actual = Command.parse("PING\r\n")
      expected = {:ok, %Command{fun: :ping, args: [""]}}

      assert actual == expected
    end

    test "ping with more than one argument" do
      actual = Command.parse("PING hello world\r\n")
      expected = {:ok, %Command{fun: :ping, args: ["hello world"]}}

      assert actual == expected
    end

    test "exists command" do
      actual = Command.parse("EXISTS hello\r\n")
      expected = {:ok, %Command{fun: :exists?, args: ["hello"]}}

      assert actual == expected
    end
  end
end
