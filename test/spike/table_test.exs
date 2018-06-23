defmodule Spike.TableTest do
  use ExUnit.Case, async: true

  alias Spike.{Table, Entry}

  setup do
    table = Table.create()
    %{table: table}
  end

  describe "keys/1" do
    test "return all defined keys", %{table: table} do
      assert :ok = Table.insert(table, Entry.create("key", "value"))
      assert :ok = Table.insert(table, Entry.create("key2", "value", 23, 15))

      actual = Table.keys(table)
      expected = ["key", "key2"]

      assert actual == expected
    end

    test "return empty array when table is empty", %{table: table} do
      actual = Table.keys(table)
      expected = []

      assert actual == expected
    end
  end

  describe "flush/1" do
    test "delete all entries", %{table: table} do
      assert :ok = Table.insert(table, Entry.create("key", "value"))
      assert :ok = Table.insert(table, Entry.create("key2", "value", 23, 15))

      assert :ok == Table.flush(table)
      assert [] == Table.keys(table)
    end
  end
end
