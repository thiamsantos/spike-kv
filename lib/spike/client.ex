defmodule Spike.Client do
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
end
