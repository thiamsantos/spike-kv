defmodule Spike.StorageTest do
  use ExUnit.Case, async: true

  test "stores values by key" do
    assert Spike.Storage.get("milk") == {:ok, nil}

    :ok = Spike.Storage.set("milk", 3)
    assert Spike.Storage.get("milk") == {:ok, 3}
  end
end
