defmodule Spike.Client do
  def get(storage, now, key) do
    {:ok, GenServer.call(storage, {:get, now, key})}
  end

  def set(storage, now, key, value) do
    GenServer.call(storage, {:set, now, key, value})
  end

  def set(storage, now, key, value, expiration) do
    GenServer.call(storage, {:set, now, key, value, expiration})
  end

  def getset(storage, now, key, value) do
    {:ok, GenServer.call(storage, {:getset, now, key, value})}
  end

  def getset(storage, now, key, value, expiration) do
    {:ok, GenServer.call(storage, {:getset, now, key, value, expiration})}
  end

  def del(storage, now, key) do
    GenServer.call(storage, {:del, now, key})
  end

  def exists?(storage, now, key) do
    {:ok, GenServer.call(storage, {:exists?, now, key})}
  end

  def ttl(storage, now, key) do
    GenServer.call(storage, {:ttl, now, key})
  end

  def rename(storage, now, oldkey, newkey) do
    GenServer.call(storage, {:rename, now, oldkey, newkey})
  end

  def ping(_storage, _now, ""), do: {:ok, "PONG"}
  def ping(_storage, _now, message), do: {:ok, message}
end
