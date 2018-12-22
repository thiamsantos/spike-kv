defmodule Spike.NimbleParserTest do
  use ExUnit.Case, async: true

  alias Spike.NimbleParser

  describe "parse/1" do
    test "set commands" do
      assert {:ok, ["SET", "key", "value"], _rest, _context, _line, _offset} =
               NimbleParser.parse("SET key value\r\n")
    end

    test "set downcase" do
      assert {:ok, ["SET", "key", "value"], _rest, _context, _line, _offset} =
               NimbleParser.parse("set key value\r\n")
    end

    test "set command with exp time" do
      assert {:ok, ["SET", "key", "value", 10], _rest, _context, _line, _offset} =
               NimbleParser.parse("SET key value 10\r\n")
    end

    test "get commands" do
      assert {:ok, ["GET", "key"], _rest, _context, _line, _offset} =
               NimbleParser.parse("GET key\r\n")
    end

    test "get downcase" do
      assert {:ok, ["GET", "key"], _rest, _context, _line, _offset} =
               NimbleParser.parse("get key\r\n")
    end

    test "del commands" do
      assert {:ok, ["DEL", "key"], _rest, _context, _line, _offset} =
               NimbleParser.parse("DEL key\r\n")
    end

    test "del downcase" do
      assert {:ok, ["DEL", "key"], _rest, _context, _line, _offset} =
               NimbleParser.parse("del key\r\n")
    end

    test "ping commmand" do
      assert {:ok, ["PING", "something"], _rest, _context, _line, _offset} =
               NimbleParser.parse("PING something\r\n")
    end

    test "ping downcase" do
      assert {:ok, ["PING", "something"], _rest, _context, _line, _offset} =
               NimbleParser.parse("ping something\r\n")
    end

    test "ping without arguments" do
      assert {:ok, ["PING"], _rest, _context, _line, _offset} = NimbleParser.parse("PING\r\n")
    end

    test "ping with more than one argument" do
      assert {:ok, ["PING", "hello world"], _rest, _context, _line, _offset} =
               NimbleParser.parse("PING \"hello world\"\r\n")
    end

    test "exists command" do
      assert {:ok, ["EXISTS", "hello"], _rest, _context, _line, _offset} =
               NimbleParser.parse("EXISTS hello\r\n")
    end

    test "exists downcase" do
      assert {:ok, ["EXISTS", "hello"], _rest, _context, _line, _offset} =
               NimbleParser.parse("exists hello\r\n")
    end

    test "getset command" do
      assert {:ok, ["GETSET", "key", "value"], _rest, _context, _line, _offset} =
               NimbleParser.parse("GETSET key value\r\n")
    end

    test "getset downcase" do
      assert {:ok, ["GETSET", "key", "value"], _rest, _context, _line, _offset} =
               NimbleParser.parse("getset key value\r\n")
    end

    test "getset command with exp" do
      assert {:ok, ["GETSET", "key", "value", 15], _rest, _context, _line, _offset} =
               NimbleParser.parse("GETSET key value 15\r\n")
    end

    test "ttl command" do
      assert {:ok, ["TTL", "key"], _rest, _context, _line, _offset} =
               NimbleParser.parse("TTL key\r\n")
    end

    test "ttl downcase" do
      assert {:ok, ["TTL", "key"], _rest, _context, _line, _offset} =
               NimbleParser.parse("ttl key\r\n")
    end

    test "rename command" do
      assert {:ok, ["RENAME", "oldkey", "newkey"], _rest, _context, _line, _offset} =
               NimbleParser.parse("RENAME oldkey newkey\r\n")
    end

    test "rename downcase" do
      assert {:ok, ["RENAME", "oldkey", "newkey"], _rest, _context, _line, _offset} =
               NimbleParser.parse("rename oldkey newkey\r\n")
    end

    test "keys command" do
      assert {:ok, ["KEYS"], _rest, _context, _line, _offset} = NimbleParser.parse("KEYS\r\n")
    end

    test "keys downcase" do
      assert {:ok, ["KEYS"], _rest, _context, _line, _offset} = NimbleParser.parse("keys\r\n")
    end

    test "flush command" do
      assert {:ok, ["FLUSH"], _rest, _context, _line, _offset} = NimbleParser.parse("FLUSH\r\n")
    end

    test "flush downcase" do
      assert {:ok, ["FLUSH"], _rest, _context, _line, _offset} = NimbleParser.parse("flush\r\n")
    end
  end
end
