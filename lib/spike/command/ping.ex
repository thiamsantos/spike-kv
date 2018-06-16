defmodule Spike.Command.Ping do
  @enforce_keys [:storage, :message]
  defstruct [:storage, :message]
end
