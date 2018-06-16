defmodule Spike.Command.Rename do
  @enforce_keys [:storage, :current_time, :oldkey, :newkey]
  defstruct [:storage, :current_time, :oldkey, :newkey]
end
