defmodule Spike.Command do
  @enforce_keys [:fun, :args]
  defstruct [:fun, :args]
end
