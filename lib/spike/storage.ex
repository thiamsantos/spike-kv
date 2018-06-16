defmodule Spike.Storage do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, :ets.new(:storage, [:protected, read_concurrency: true])}
  end

  def handle_call({:set, _now, key, value}, _from, table) do
    true = :ets.insert(table, {key, value})
    {:reply, :ok, table}
  end

  def handle_call({:set, now, key, value, expiration}, _from, table) do
    true = :ets.insert(table, {key, value, expiration, now})
    {:reply, :ok, table}
  end

  def handle_call({:get, now, key}, _from, table) do
    case find(table, key, now) do
      {:ok, value} ->
        {:reply, {:ok, value}, table}

      :error ->
        {:reply, {:ok, nil}, table}
    end
  end

  def handle_call({:del, _now, key}, _from, table) do
    true = :ets.delete(table, key)
    {:reply, :ok, table}
  end

  def handle_call({:exists?, now, key}, _from, table) do
    case find(table, key, now) do
      {:ok, _value} ->
        {:reply, {:ok, true}, table}

      :error ->
        {:reply, {:ok, false}, table}
    end
  end

  def handle_call({:getset, now, key, value}, _from, table) do
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

  def handle_call({:getset, now, key, value, expiration}, _from, table) do
    old_value =
      case find(table, key, now) do
        {:ok, value} ->
          value

        :error ->
          nil
      end

    true = :ets.insert(table, {key, value, expiration, now})
    {:reply, {:ok, old_value}, table}
  end

  def handle_call({:ttl, now, key}, _from, table) do
    response =
      case :ets.lookup(table, key) do
        [{^key, _value, expiration, inserted_at}] ->
          lazy_expire_or_return_ttl(table, key, expiration, inserted_at, now)

        [{^key, _value}] ->
          {:error, 1}

        [] ->
          {:error, 2}
      end

    {:reply, response, table}
  end

  def handle_call({:ping, message}, _from, table) do
    {:reply, {:ok, message}, table}
  end

  def handle_call({:rename, now, oldkey, newkey}, _from, table) do
    response =
      case :ets.lookup(table, oldkey) do
        [{^oldkey, value, expiration, inserted_at}] ->
          if expired?(now, expiration, inserted_at) do
            :error
          else
            {newkey, value, expiration, inserted_at}
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

        {key, value, expiration, now} ->
          true = :ets.insert(table, {key, value, expiration, now})
          :ok

        :error ->
          :error
      end

    {:reply, reply, table}
  end

  defp find(table, key, now) do
    case :ets.lookup(table, key) do
      [{^key, value, expiration, inserted_at}] ->
        lazy_expire_or_return_value(table, key, value, expiration, inserted_at, now)

      [{^key, value}] ->
        {:ok, value}

      [] ->
        :error
    end
  end

  defp lazy_expire_or_return_value(table, key, value, expiration, inserted_at, now) do
    if expired?(now, expiration, inserted_at) do
      true = :ets.delete(table, key)
      :error
    else
      {:ok, value}
    end
  end

  defp lazy_expire_or_return_ttl(table, key, expiration, inserted_at, now) do
    if expired?(now, expiration, inserted_at) do
      true = :ets.delete(table, key)
      {:error, 2}
    else
      ttl = inserted_at + expiration - now
      {:ok, ttl}
    end
  end

  defp expired?(now, expiration, inserted_at) do
    now >= expiration + inserted_at
  end
end
