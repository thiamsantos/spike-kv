defmodule Spike.Command.Getset do
  @enforce_keys [:storage, :current_time, :key, :value]
  defstruct [:storage, :current_time, :key, :value, :expiration]
end
