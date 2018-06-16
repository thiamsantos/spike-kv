defmodule Spike.Storage do
  use GenServer

  alias Spike.Command.{Get, Set, Del, Ping, Exists, Ttl, Rename, Getset}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, :ets.new(:storage, [:protected, read_concurrency: true])}
  end

  def handle_call({%Set{key: key, value: value, exp: exp}, now}, _from, table)
      when not is_nil(exp) do
    true = :ets.insert(table, {key, value, exp, now})
    {:reply, :ok, table}
  end

  def handle_call({%Set{key: key, value: value}, _now}, _from, table) do
    true = :ets.insert(table, {key, value})
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
    true = :ets.delete(table, key)
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

    true = :ets.insert(table, {key, value, exp, now})
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

    true = :ets.insert(table, {key, value})
    {:reply, {:ok, old_value}, table}
  end

  def handle_call({%Ttl{key: key}, now}, _from, table) do
    response =
      case :ets.lookup(table, key) do
        [{^key, _value, exp, inserted_at}] ->
          lazy_expire_or_return_ttl(table, key, exp, inserted_at, now)

        [{^key, _value}] ->
          {:error, 1}

        [] ->
          {:error, 2}
      end

    {:reply, response, table}
  end

  def handle_call({%Ping{message: message}, _now}, _from, table) do
    {:reply, {:ok, message}, table}
  end

  def handle_call({%Rename{oldkey: oldkey, newkey: newkey}, now}, _from, table) do
    response =
      case :ets.lookup(table, oldkey) do
        [{^oldkey, value, exp, inserted_at}] ->
          if expired?(now, exp, inserted_at) do
            :error
          else
            {newkey, value, exp, inserted_at}
          end

        [{^oldkey, value}] ->
          {newkey, value}

        [] ->
          :error
      end

    true = :ets.delete(table, oldkey)

    reply =
      case response do
        {key, value} ->
          true = :ets.insert(table, {key, value})
          :ok

        {key, value, exp, now} ->
          true = :ets.insert(table, {key, value, exp, now})
          :ok

        :error ->
          :error
      end

    {:reply, reply, table}
  end

  defp find(table, key, now) do
    case :ets.lookup(table, key) do
      [{^key, value, exp, inserted_at}] ->
        lazy_expire_or_return_value(table, key, value, exp, inserted_at, now)

      [{^key, value}] ->
        {:ok, value}

      [] ->
        :error
    end
  end

  defp lazy_expire_or_return_value(table, key, value, exp, inserted_at, now) do
    if expired?(now, exp, inserted_at) do
      true = :ets.delete(table, key)
      :error
    else
      {:ok, value}
    end
  end

  defp lazy_expire_or_return_ttl(table, key, exp, inserted_at, now) do
    if expired?(now, exp, inserted_at) do
      true = :ets.delete(table, key)
      {:error, 2}
    else
      ttl = inserted_at + exp - now
      {:ok, ttl}
    end
  end

  defp expired?(now, exp, inserted_at) do
    now >= exp + inserted_at
  end
end
