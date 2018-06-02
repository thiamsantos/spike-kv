defmodule Spike.StorageTest do
  use ExUnit.Case, async: true

  alias Spike.{Storage, Client}

  setup do
    storage = start_supervised!(Storage)
    %{storage: storage}
  end

  test "stores values by key", %{storage: storage} do
    assert Client.get(storage, "milk") == {:ok, nil}

    :ok = Client.set(storage, "milk", 3)
    assert Client.get(storage, "milk") == {:ok, 3}
  end

  test "values with expiration time", %{storage: storage} do
    now = 1
    assert Client.get(storage, "milk") == {:ok, nil}

    :ok = Client.set(storage, "milk", 3, 10, now)
    assert Client.get(storage, "milk", now + 9) == {:ok, 3}

    assert Client.get(storage, "milk", now + 10) == {:ok, nil}
  end

  test "delete keys", %{storage: storage} do
    assert Client.get(storage, "milk") == {:ok, nil}

    :ok = Client.set(storage, "milk", 3)
    assert Client.get(storage, "milk") == {:ok, 3}

    :ok = Client.del(storage, "milk")

    assert Client.get(storage, "milk") == {:ok, nil}
  end

  test "ping", %{storage: storage} do
    assert Client.ping(storage, "") == {:ok, "PONG"}
    assert Client.ping(storage, "hello world") == {:ok, "hello world"}
  end

  test "exists", %{storage: storage} do
    assert Client.exists?(storage, "milk") == {:ok, false}

    :ok = Client.set(storage, "milk", 3)
    assert Client.exists?(storage, "milk") == {:ok, true}
  end

  test "exists with expiration", %{storage: storage} do
    now = 1
    assert Client.exists?(storage, "milk") == {:ok, false}

    :ok = Client.set(storage, "milk", 3, 10, now)
    assert Client.exists?(storage, "milk", now + 9) == {:ok, true}
    assert Client.exists?(storage, "milk", now + 10) == {:ok, false}
  end
end
