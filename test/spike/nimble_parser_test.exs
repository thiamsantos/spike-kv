defmodule Spike.NimbleParserTest do
  use ExUnit.Case, async: true

  alias Spike.NimbleParser

  describe "parse/1" do
    test "set commands" do
      assert {:ok, [:set, "key", "value"], _rest, _context, _line, _offset} =
               NimbleParser.parse("SET key value\r\n")
    end

    test "set command with exp time" do
      assert {:ok, [:set, "key", "value", 10], _rest, _context, _line, _offset} =
               NimbleParser.parse("SET key value 10\r\n")
    end

    test "get commands" do
      assert {:ok, [:get, "key"], _rest, _context, _line, _offset} =
               NimbleParser.parse("GET key\r\n")
    end

    test "del commands" do
      assert {:ok, [:del, "key"], _rest, _context, _line, _offset} =
               NimbleParser.parse("DEL key\r\n")
    end

    test "ping commmand" do
      assert {:ok, [:ping, "something"], _rest, _context, _line, _offset} =
               NimbleParser.parse("PING something\r\n")
    end

    test "ping without arguments" do
      assert {:ok, [:ping], _rest, _context, _line, _offset} = NimbleParser.parse("PING\r\n")
    end

    test "ping with more than one argument" do
      assert {:ok, [:ping, "hello world"], _rest, _context, _line, _offset} =
               NimbleParser.parse("PING \"hello world\"\r\n")
    end

    test "exists command" do
      assert {:ok, [:exists, "hello"], _rest, _context, _line, _offset} =
               NimbleParser.parse("EXISTS hello\r\n")
    end

    test "getset command" do
      assert {:ok, [:getset, "key", "value"], _rest, _context, _line, _offset} =
               NimbleParser.parse("GETSET key value\r\n")
    end

    test "getset command with exp" do
      assert {:ok, [:getset, "key", "value", 15], _rest, _context, _line, _offset} =
               NimbleParser.parse("GETSET key value 15\r\n")
    end

    test "ttl command" do
      assert {:ok, [:ttl, "key"], _rest, _context, _line, _offset} =
               NimbleParser.parse("TTL key\r\n")
    end

    test "rename command" do
      assert {:ok, [:rename, "oldkey", "newkey"], _rest, _context, _line, _offset} =
               NimbleParser.parse("RENAME oldkey newkey\r\n")
    end

    test "keys command" do
      assert {:ok, [:keys], _rest, _context, _line, _offset} = NimbleParser.parse("KEYS\r\n")
    end

    test "flush command" do
      assert {:ok, [:flush], _rest, _context, _line, _offset} = NimbleParser.parse("FLUSH\r\n")
    end
  end
end
