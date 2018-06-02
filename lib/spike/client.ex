defmodule Spike.Client do
  def set(storage, _now, key, value) do
    GenServer.call(storage, {:set, key, value})
  end

  def set(storage, now, key, value, expiration) do
    GenServer.call(storage, {:set, key, value, expiration, now})
  end

  def get(storage, now, key) do
    {:ok, GenServer.call(storage, {:get, key, now})}
  end

  def del(storage, _now, key) do
    GenServer.call(storage, {:del, key})
  end

  def ping(_storage, _now, ""), do: {:ok, "PONG"}
  def ping(_storage, _now, message), do: {:ok, message}

  def exists?(storage, now, key) do
    {:ok, GenServer.call(storage, {:exists?, key, now})}
  end
end
