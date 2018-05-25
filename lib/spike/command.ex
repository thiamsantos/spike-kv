defmodule Spike.Command do
  @enforce_keys [:fun, :args]
  defstruct [:fun, :args]

  def parse(command) do
    case String.split(command) do
      ["GET", key] -> {:ok, create(:get, [key])}
      ["SET", key, value] -> {:ok, create(:set, [key, value])}
      ["DEL", key] -> {:ok, create(:del, [key])}
      ["PING" | message] -> {:ok, create(:ping, [Enum.join(message, " ")])}
      ["EXISTS", key] -> {:ok, create(:exists?, [key])}
      _ -> {:error, :unknown_command}
    end
  end

  def create(fun, args) do
    %__MODULE__{fun: fun, args: args}
  end
end
