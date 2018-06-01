defmodule Spike.Command do
  @enforce_keys [:fun, :args]
  defstruct [:fun, :args]

  def parse(command) do
    case String.split(command) do
      ["GET", key] -> {:ok, create(:get, [key])}
      ["SET", key, value] -> {:ok, create(:set, [key, value])}
      ["SET", key, value, expiration] -> parse_command_with_expiration(:set, [key, value], expiration)
      ["DEL", key] -> {:ok, create(:del, [key])}
      ["PING" | message] -> {:ok, create(:ping, [Enum.join(message, " ")])}
      ["EXISTS", key] -> {:ok, create(:exists?, [key])}
      _ -> {:error, :unknown_command}
    end
  end

  defp parse_command_with_expiration(fun, args, expiration) do
    case parse_expiration(expiration) do
      expiration_time when is_integer(expiration_time) ->
        {:ok, create(fun, args ++ [expiration_time])}
      :error ->
        {:error, :unknown_command}
    end
  end

  defp parse_expiration(expiration) do
    if Regex.match?(~r/^\d+$/, expiration) do
      String.to_integer(expiration)
    else
      :error
    end
  end

  defp create(fun, args) do
    %__MODULE__{fun: fun, args: args}
  end
end
