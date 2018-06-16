defmodule Spike.Command.Rename do
  @enforce_keys [:oldkey, :newkey]
  defstruct [:oldkey, :newkey]
end
