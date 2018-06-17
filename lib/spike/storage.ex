defmodule Spike.Storage do
  use GenServer

  import Spike.Entry, only: [is_entry: 1]

  alias Spike.Command.{Get, Set, Del, Ping, Exists, Ttl, Rename, Getset, Error}
  alias Spike.{VolatileEntry, StableEntry, Table, Entry}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, Table.create()}
  end

  def handle_call({%Set{key: key, value: value, exp: exp}, now}, _from, table)
      when not is_nil(exp) do
    :ok = Table.insert(table, Entry.create(key, value, exp, now))
    {:reply, :ok, table}
  end

  def handle_call({%Set{key: key, value: value}, _now}, _from, table) do
    :ok = Table.insert(table, Entry.create(key, value))
    {:reply, :ok, table}
  end

  def handle_call({%Get{key: key}, now}, _from, table) do
    case Table.lookup(table, key, now) do
      %e{value: value} when is_entry(e) ->
        {:reply, {:ok, value}, table}

      nil ->
        {:reply, {:ok, nil}, table}
    end
  end

  def handle_call({%Del{key: key}, _now}, _from, table) do
    :ok = Table.delete(table, key)
    {:reply, :ok, table}
  end

  def handle_call({%Exists{key: key}, now}, _from, table) do
    case Table.lookup(table, key, now) do
      %e{} when is_entry(e) ->
        {:reply, {:ok, true}, table}

      nil ->
        {:reply, {:ok, false}, table}
    end
  end

  def handle_call({%Getset{key: key, value: value, exp: exp}, now}, _from, table)
      when not is_nil(exp) do
    case Table.lookup(table, key, now) do
      %e{value: old_value} when is_entry(e) ->
        :ok = Table.insert(table, Entry.create(key, value, exp, now))

        {:reply, {:ok, old_value}, table}

      nil ->
        {:reply, {:ok, nil}, table}
    end
  end

  def handle_call({%Getset{key: key, value: value}, now}, _from, table) do
    case Table.lookup(table, key, now) do
      entry = %e{value: old_value} when is_entry(e) ->
        :ok = Table.insert(table, Map.put(entry, :value, value))
        {:reply, {:ok, old_value}, table}

      nil ->
        {:reply, {:ok, nil}, table}
    end
  end

  def handle_call({%Ttl{key: key}, now}, _from, table) do
    case Table.lookup(table, key, now) do
      %VolatileEntry{exp: exp, inserted_at: inserted_at} ->
        ttl = inserted_at + exp - now
        {:reply, {:ok, ttl}, table}

      %StableEntry{} ->
        {:reply, {:error, 1}, table}

      nil ->
        {:reply, {:error, 2}, table}
    end
  end

  def handle_call({%Ping{message: message}, _now}, _from, table) do
    {:reply, {:ok, message}, table}
  end

  def handle_call({%Rename{oldkey: oldkey, newkey: newkey}, now}, _from, table) do
    case Table.lookup(table, oldkey, now) do
      entry = %e{} when is_entry(e) ->
        :ok = Table.delete(table, oldkey)
        :ok = Table.insert(table, Map.put(entry, :key, newkey))
        {:reply, :ok, table}

      nil ->
        {:reply, :error, table}
    end
  end

  def handle_call({%Error{message: message}, _now}, _from, table) do
    {:reply, {:error, message}, table}
  end
end
