defmodule Spike.StorageTest do
  use ExUnit.Case, async: true

  alias Spike.{Storage, Client}

  setup do
    storage = start_supervised!(Storage)
    %{storage: storage}
  end

  setup do
    now = :rand.uniform(1_000)
    %{now: now}
  end

  test "stores values by key", %{storage: storage, now: now} do
    assert Client.get(storage, now, "milk") == {:ok, nil}

    :ok = Client.set(storage, now, "milk", 3)
    assert Client.get(storage, now, "milk") == {:ok, 3}
  end

  test "values with expiration time", %{storage: storage, now: now} do
    assert Client.get(storage, now, "milk") == {:ok, nil}

    :ok = Client.set(storage, now, "milk", 3, 10)
    assert Client.get(storage, now + 9, "milk") == {:ok, 3}

    assert Client.get(storage, now + 10, "milk") == {:ok, nil}
  end

  test "delete keys", %{storage: storage, now: now} do
    assert Client.get(storage, now, "milk") == {:ok, nil}

    :ok = Client.set(storage, now, "milk", 3)
    assert Client.get(storage, now, "milk") == {:ok, 3}

    :ok = Client.del(storage, now, "milk")

    assert Client.get(storage, now, "milk") == {:ok, nil}
  end

  test "ping", %{storage: storage, now: now} do
    assert Client.ping(storage, now, "") == {:ok, "PONG"}
    assert Client.ping(storage, now, "hello world") == {:ok, "hello world"}
  end

  test "exists", %{storage: storage, now: now} do
    assert Client.exists?(storage, now, "milk") == {:ok, false}

    :ok = Client.set(storage, now, "milk", 3)
    assert Client.exists?(storage, now, "milk") == {:ok, true}
  end

  test "exists with expiration", %{storage: storage, now: now} do
    assert Client.exists?(storage, now, "milk") == {:ok, false}

    :ok = Client.set(storage, now, "milk", 3, 10)
    assert Client.exists?(storage, now + 9, "milk") == {:ok, true}
    assert Client.exists?(storage, now + 10, "milk") == {:ok, false}
  end

  test "getset", %{storage: storage, now: now} do
    assert Client.get(storage, now, "milk") == {:ok, nil}

    :ok = Client.set(storage, now, "milk", 3)
    assert Client.getset(storage, now, "milk", 4) == {:ok, 3}
    assert Client.get(storage, now, "milk") == {:ok, 4}
  end

  test "getset with expiration", %{storage: storage, now: now} do
    assert Client.get(storage, now, "milk") == {:ok, nil}

    :ok = Client.set(storage, now, "milk", 3)
    assert Client.getset(storage, now, "milk", 4, 10) == {:ok, 3}
    assert Client.get(storage, now + 9, "milk") == {:ok, 4}
    assert Client.get(storage, now + 10, "milk") == {:ok, nil}
  end

  test "ttl", %{storage: storage, now: now} do
    assert Client.ttl(storage, now, "milk") == {:error, 2}

    :ok = Client.set(storage, now, "milk", 3, 10)
    assert Client.ttl(storage, now, "milk") == {:ok, 10}

    :ok = Client.set(storage, now, "basket", "eggs")
    assert Client.ttl(storage, now, "basket") == {:error, 1}
  end
end
