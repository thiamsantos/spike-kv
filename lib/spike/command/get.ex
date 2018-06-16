defmodule Spike.Command.Get do
  @enforce_keys [:storage, :current_time, :key]
  defstruct [:storage, :current_time, :key]
end
