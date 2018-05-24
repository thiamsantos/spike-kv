defmodule Spike.CommandTest do
  use ExUnit.Case, async: true

  alias Spike.Command

  describe "parse/1" do
    test "set commands" do
      actual = Command.parse("SET key value\r\n")
      expected = {:ok, %{fun: :set, args: ["key", "value"]}}

      assert actual == expected
    end

    test "get commands" do
      actual = Command.parse("GET key\r\n")
      expected = {:ok, %{fun: :get, args: ["key"]}}

      assert actual == expected
    end

    test "lf line breaks" do
      actual = Command.parse("GET key\n")
      expected = {:ok, %{fun: :get, args: ["key"]}}

      assert actual == expected
    end

    test "unknown command if missing arguments" do
      actual = Command.parse("SET key\r\n")
      expected = {:error, :unknown_command}

      assert actual == expected
    end
  end
end
