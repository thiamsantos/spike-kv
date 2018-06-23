defmodule Spike.LexerTest do
  use ExUnit.Case, async: true

  alias Spike.Lexer

  describe "run/1" do
    test "basic key value" do
      actual = Lexer.run(~s(SET key value))
      expected = ["SET", "key", "value"]

      assert actual == expected
    end

    test "value with whitespace" do
      actual = Lexer.run(~s(SET key "value with whitespace"))
      expected = ["SET", "key", "value with whitespace"]

      assert actual == expected
    end

    test "value with number" do
      actual = Lexer.run(~s(SET key 12))
      expected = ["SET", "key", 12]

      assert actual == expected
    end

    test "space is not significant" do
      actual = Lexer.run(~s(    SET  key   value ))
      expected = ["SET", "key", "value"]

      assert actual == expected
    end

    test "breakline is not significant" do
      actual = Lexer.run(~s(    SET  key   value \r\n))
      expected = ["SET", "key", "value"]

      assert actual == expected
    end

    test "value with breakline" do
      actual = Lexer.run(~s(SET key "value \r\n"))
      expected = ["SET", "key", "value \r\n"]

      assert actual == expected
    end

    test "mixed" do
      actual = Lexer.run(~s("value \r\n" 12))
      expected = ["value \r\n", 12]

      assert actual == expected
    end
  end
end
