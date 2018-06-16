defmodule Spike.StableEntry do
  @enforce_keys [:key, :value]
  defstruct [:key, :value]
end
