defmodule Spike.Storage do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> Map.new() end, name: __MODULE__)
  end

  def set(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def get(key) do
    {:ok, Agent.get(__MODULE__, &Map.get(&1, key))}
  end
end
