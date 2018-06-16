defmodule Spike.Storage do
  use GenServer

  alias Spike.Command.{Get, Set, Del, Ping, Exists, Ttl, Rename, Getset, Error}
  alias Spike.Table

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, Table.create()}
  end

  def handle_call({%Set{key: key, value: value, exp: exp}, now}, _from, table)
      when not is_nil(exp) do
    :ok = Table.insert(table, {key, value, exp, now})
    {:reply, :ok, table}
  end

  def handle_call({%Set{key: key, value: value}, _now}, _from, table) do
    :ok = Table.insert(table, {key, value})
    {:reply, :ok, table}
  end

  def handle_call({%Get{key: key}, now}, _from, table) do
    case find(table, key, now) do
      {:ok, value} ->
        {:reply, {:ok, value}, table}

      :error ->
        {:reply, {:ok, nil}, table}
    end
  end

  def handle_call({%Del{key: key}, _now}, _from, table) do
    :ok = Table.delete(table, key)
    {:reply, :ok, table}
  end

  def handle_call({%Exists{key: key}, now}, _from, table) do
    case find(table, key, now) do
      {:ok, _value} ->
        {:reply, {:ok, true}, table}

      :error ->
        {:reply, {:ok, false}, table}
    end
  end

  def handle_call({%Getset{key: key, value: value, exp: exp}, now}, _from, table)
      when not is_nil(exp) do
    old_value =
      case find(table, key, now) do
        {:ok, value} ->
          value

        :error ->
          nil
      end

    :ok = Table.insert(table, {key, value, exp, now})
    {:reply, {:ok, old_value}, table}
  end

  def handle_call({%Getset{key: key, value: value}, now}, _from, table) do
    old_value =
      case find(table, key, now) do
        {:ok, value} ->
          value

        :error ->
          nil
      end

    :ok = Table.insert(table, {key, value})
    {:reply, {:ok, old_value}, table}
  end

  def handle_call({%Ttl{key: key}, now}, _from, table) do
    response =
      case Table.lookup(table, key, now) do
        {^key, _value, exp, inserted_at} ->
          ttl = inserted_at + exp - now
          {:ok, ttl}

        {^key, _value} ->
          {:error, 1}

        nil ->
          {:error, 2}
      end

    {:reply, response, table}
  end

  def handle_call({%Ping{message: message}, _now}, _from, table) do
    {:reply, {:ok, message}, table}
  end

  def handle_call({%Rename{oldkey: oldkey, newkey: newkey}, now}, _from, table) do
    response =
      case Table.lookup(table, oldkey, now) do
        {^oldkey, value, exp, inserted_at} ->
          {newkey, value, exp, inserted_at}

        {^oldkey, value} ->
          {newkey, value}

        nil ->
          :error
      end

    :ok = Table.delete(table, oldkey)

    reply =
      case response do
        {key, value} ->
          :ok = Table.insert(table, {key, value})
          :ok

        {key, value, exp, now} ->
          :ok = Table.insert(table, {key, value, exp, now})
          :ok

        :error ->
          :error
      end

    {:reply, reply, table}
  end

  def handle_call({%Error{message: message}, _now}, _from, table) do
    {:reply, {:error, message}, table}
  end

  defp find(table, key, now) do
    case Table.lookup(table, key, now) do
      {^key, value, exp, inserted_at} ->
        {:ok, value}

      {^key, value} ->
        {:ok, value}

      nil ->
        :error
    end
  end
end
