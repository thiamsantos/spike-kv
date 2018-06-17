defmodule Spike.Entry do
  alias Spike.{VolatileEntry, StableEntry}

  def parse({key, value}) do
    %StableEntry{key: key, value: value}
  end

  def parse({key, value, exp, inserted_at}) do
    %VolatileEntry{key: key, value: value, exp: exp, inserted_at: inserted_at}
  end

  def serialize(%StableEntry{key: key, value: value}) do
    {key, value}
  end

  def serialize(%VolatileEntry{key: key, value: value, exp: exp, inserted_at: inserted_at}) do
    {key, value, exp, inserted_at}
  end

  def create(key, value) do
    %StableEntry{key: key, value: value}
  end

  def create(key, value, exp, inserted_at) do
    %VolatileEntry{key: key, value: value, exp: exp, inserted_at: inserted_at}
  end

  defguard is_entry(entry) when entry in [VolatileEntry, StableEntry]
end
