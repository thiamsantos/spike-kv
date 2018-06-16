defmodule Spike.Command.Getset do
  @enforce_keys [:key, :value]
  defstruct [:key, :value, :exp]
end
