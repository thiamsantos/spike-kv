defmodule Spike.VolatileEntry do
  @enforce_keys [:key, :value, :exp, :inserted_at]
  defstruct [:key, :value, :exp, :inserted_at]
end
