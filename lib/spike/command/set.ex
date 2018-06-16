defmodule Spike.Command.Set do
  @enforce_keys [:key, :value]
  defstruct [:key, :value, :exp]
end
