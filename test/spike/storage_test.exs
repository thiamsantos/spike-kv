defmodule Spike.StorageTest do
  use ExUnit.Case, async: true

  alias Spike.{Storage, Command, Request}
  alias Spike.Command.{Get, Set, Del, Exists, Ping, Getset, Rename, Ttl}

  setup do
    storage = start_supervised!(Storage)
    %{storage: storage}
  end

  setup do
    now = :rand.uniform(1_000)
    %{now: now}
  end

  defp run(storage, now, command) do
    %Request{storage: storage, now: now, command: command}
    |> Command.run()
  end

  test "stores values by key", %{storage: storage, now: now} do
    assert run(storage, now, %Get{key: "milk"}) == {:ok, nil}

    assert :ok = run(storage, now, %Set{key: "milk", value: 3})

    assert run(storage, now, %Get{key: "milk"}) == {:ok, 3}
  end

  test "values with exp time", %{storage: storage, now: now} do
    assert run(storage, now, %Get{key: "milk"}) == {:ok, nil}

    assert :ok = run(storage, now, %Set{key: "milk", value: 3, exp: 10})
    assert run(storage, now + 9, %Get{key: "milk"}) == {:ok, 3}

    assert run(storage, now + 10, %Get{key: "milk"}) == {:ok, nil}
  end

  test "delete keys", %{storage: storage, now: now} do
    assert run(storage, now, %Get{key: "milk"}) == {:ok, nil}

    assert :ok = run(storage, now, %Set{key: "milk", value: 3})
    assert run(storage, now, %Get{key: "milk"}) == {:ok, 3}

    assert :ok = run(storage, now, %Del{key: "milk"})

    assert run(storage, now, %Get{key: "milk"}) == {:ok, nil}
  end

  test "ping", %{storage: storage, now: now} do
    assert run(storage, now, %Ping{message: "PONG"}) == {:ok, "PONG"}
    assert run(storage, now, %Ping{message: "hello world"}) == {:ok, "hello world"}
  end

  test "exists", %{storage: storage, now: now} do
    assert run(storage, now, %Exists{key: "milk"}) == {:ok, false}

    assert :ok = run(storage, now, %Set{key: "milk", value: 3})
    assert run(storage, now, %Exists{key: "milk"}) == {:ok, true}
  end

  test "exists with exp", %{storage: storage, now: now} do
    assert run(storage, now, %Exists{key: "milk"}) == {:ok, false}

    assert :ok = run(storage, now, %Set{key: "milk", value: 3, exp: 10})
    assert run(storage, now + 9, %Exists{key: "milk"}) == {:ok, true}
    assert run(storage, now + 10, %Exists{key: "milk"}) == {:ok, false}
  end

  test "getset", %{storage: storage, now: now} do
    assert run(storage, now, %Get{key: "milk"}) == {:ok, nil}

    assert :ok = run(storage, now, %Set{key: "milk", value: 3})
    assert run(storage, now, %Getset{key: "milk", value: 4}) == {:ok, 3}
    assert run(storage, now, %Get{key: "milk"}) == {:ok, 4}
  end

  test "getset with exp", %{storage: storage, now: now} do
    assert run(storage, now, %Get{key: "milk"}) == {:ok, nil}

    assert :ok = run(storage, now, %Set{key: "milk", value: 3})
    assert run(storage, now, %Getset{key: "milk", value: 4, exp: 10}) == {:ok, 3}
    assert run(storage, now + 9, %Get{key: "milk"}) == {:ok, 4}
    assert run(storage, now + 10, %Get{key: "milk"}) == {:ok, nil}
  end

  test "ttl", %{storage: storage, now: now} do
    assert run(storage, now, %Ttl{key: "milk"}) == {:error, 2}

    assert :ok = run(storage, now, %Set{key: "milk", value: 3, exp: 10})
    assert run(storage, now, %Ttl{key: "milk"}) == {:ok, 10}

    assert :ok = run(storage, now, %Set{key: "basket", value: "eggs"})
    assert run(storage, now, %Ttl{key: "basket"}) == {:error, 1}
  end

  test "rename", %{storage: storage, now: now} do
    assert run(storage, now, %Rename{oldkey: "oldkey", newkey: "newkey"}) == :error

    assert :ok = run(storage, now, %Set{key: "oldkey", value: 3, exp: 10})
    assert run(storage, now, %Rename{oldkey: "oldkey", newkey: "newkey"}) == :ok
    assert run(storage, now, %Ttl{key: "newkey"}) == {:ok, 10}
    assert run(storage, now, %Get{key: "newkey"}) == {:ok, 3}
    assert run(storage, now, %Exists{key: "oldkey"}) == {:ok, false}
  end

  test "rename with exp", %{storage: storage, now: now} do
    assert :ok = run(storage, now, %Set{key: "oldkey", value: 3, exp: 10})
    assert run(storage, now + 11, %Rename{oldkey: "oldkey", newkey: "newkey"}) == :error
  end

  test "rename key without exp", %{storage: storage, now: now} do
    assert :ok = run(storage, now, %Set{key: "oldkey", value: 3})
    assert run(storage, now, %Rename{oldkey: "oldkey", newkey: "newkey"}) == :ok
    assert run(storage, now, %Get{key: "newkey"}) == {:ok, 3}
    assert run(storage, now, %Exists{key: "oldkey"}) == {:ok, false}
  end
end
