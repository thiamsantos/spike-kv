defmodule Spike.Storage do
  use GenServer

  # Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def set(storage, key, value) do
    GenServer.call(storage, {:set, key, value})
  end

  def set(storage, key, value, expiration, now \\ :os.system_time(:seconds)) do
    GenServer.call(storage, {:set, key, value, expiration, now})
  end

  def get(storage, key, now \\ :os.system_time(:seconds)) do
    {:ok, GenServer.call(storage, {:get, key, now})}
  end

  def del(storage, key) do
    GenServer.call(storage, {:del, key})
  end

  def ping(_storage, ""), do: {:ok, "PONG"}
  def ping(_storage, message), do: {:ok, message}

  def exists?(storage, key, now \\ :os.system_time(:seconds)) do
    {:ok, GenServer.call(storage, {:exists?, key, now})}
  end

  # Server (callbacks)

  def init(_) do
    {:ok, :ets.new(:storage, [:protected, read_concurrency: true])}
  end

  def handle_call({:set, key, value}, _from, table) do
    true = :ets.insert(table, {key, value})
    {:reply, :ok, table}
  end

  def handle_call({:set, key, value, expiration, inserted_at}, _from, table) do
    true = :ets.insert(table, {key, value, expiration, inserted_at})
    {:reply, :ok, table}
  end

  def handle_call({:get, key, now}, _from, table) do
    case find(table, key, now) do
      {:ok, value} ->
        {:reply, value, table}

      :error ->
        {:reply, nil, table}
    end
  end

  def handle_call({:del, key}, _from, table) do
    true = :ets.delete(table, key)
    {:reply, :ok, table}
  end

  def handle_call({:exists?, key, now}, _from, table) do
    case find(table, key, now) do
      {:ok, _value} ->
        {:reply, true, table}

      :error ->
        {:reply, false, table}
    end
  end

  defp find(table, key, now) do
    case :ets.lookup(table, key) do
      [{^key, value, expiration, inserted_at}] -> lazy_expire_or_return(table, key, value, expiration, inserted_at, now)
      [{^key, value}] -> {:ok, value}
      [] -> :error
    end
  end

  defp lazy_expire_or_return(table, key, value, expiration, inserted_at, now) do
    if expiration + inserted_at > now do
      {:ok, value}
    else
      true = :ets.delete(table, key)
      :error
    end
  end
end
