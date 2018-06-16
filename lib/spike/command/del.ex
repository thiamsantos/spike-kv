defmodule Spike.Command.Del do
  @enforce_keys [:storage, :current_time, :key]
  defstruct [:storage, :current_time, :key]
end
