defmodule Spike.StorageTest do
  use ExUnit.Case, async: true

  setup do
    start_supervised!(Spike.Storage)
    :ok
  end

  test "stores values by key" do
    assert Spike.Storage.get("milk") == nil

    Spike.Storage.set("milk", 3)
    assert Spike.Storage.get("milk") == 3
  end
end
