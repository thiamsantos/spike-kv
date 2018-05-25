defmodule Spike.Storage do
  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> Map.new() end, opts)
  end

  def set(storage, key, value) do
    Agent.update(storage, &Map.put(&1, key, value))
  end

  def get(storage, key) do
    {:ok, Agent.get(storage, &Map.get(&1, key))}
  end

  def del(storage, key) do
    Agent.update(storage, &Map.delete(&1, key))
  end

  def ping(_storage, ""), do: {:ok, "PONG"}
  def ping(_storage, message), do: {:ok, message}

  def exists?(storage, key) do
    {:ok, Agent.get(storage, &Map.has_key?(&1, key))}
  end
end
