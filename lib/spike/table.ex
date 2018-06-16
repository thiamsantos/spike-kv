defmodule Spike.Table do
  def create do
    :ets.new(:storage, [:protected, read_concurrency: true])
  end

  def insert(table, content) do
    true = :ets.insert(table, content)
    :ok
  end

  def lookup(table, key, now) do
    case :ets.lookup(table, key) do
      [{^key, value, exp, inserted_at}] ->
        if expired?(now, exp, inserted_at) do
          :ok = delete(table, key)
          nil
        else
          {key, value, exp, inserted_at}
        end

      [{^key, value}] ->
        {key, value}

      [] ->
        nil
    end
  end

  def delete(table, key) do
    true = :ets.delete(table, key)
    :ok
  end

  defp expired?(now, exp, inserted_at) do
    now >= exp + inserted_at
  end
end
