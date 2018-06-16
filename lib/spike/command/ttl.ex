defmodule Spike.Command.Ttl do
  @enforce_keys [:storage, :current_time, :key]
  defstruct [:storage, :current_time, :key]
end
