defmodule Spike.StorageTest do
  use ExUnit.Case, async: true

  alias Spike.Storage

  setup do
    storage = start_supervised!(Storage)
    %{storage: storage}
  end

  test "stores values by key", %{storage: storage} do
    assert Storage.get(storage, "milk") == {:ok, nil}

    :ok = Storage.set(storage, "milk", 3)
    assert Storage.get(storage, "milk") == {:ok, 3}
  end

  test "delete keys", %{storage: storage} do
    assert Storage.get(storage, "milk") == {:ok, nil}

    :ok = Storage.set(storage, "milk", 3)
    assert Storage.get(storage, "milk") == {:ok, 3}

    :ok = Storage.del(storage, "milk")

    assert Storage.get(storage, "milk") == {:ok, nil}
  end

  test "ping", %{storage: storage} do
    assert Storage.ping(storage, "") == {:ok, "PONG"}
    assert Storage.ping(storage, "hello world") == {:ok, "hello world"}
  end

  test "exists", %{storage: storage} do
    assert Storage.exists?(storage, "milk") == {:ok, false}

    :ok = Storage.set(storage, "milk", 3)
    assert Storage.exists?(storage, "milk") == {:ok, true}
  end
end
