defmodule Spike.Parser do
  alias Spike.Command.{Get, Set, Del, Ping, Exists, Ttl, Rename, Getset}

  def parse(command) do
    case String.split(command) do
      ["GET", key] ->
        {:ok, %Get{key: key}}

      ["SET", key, value] ->
        {:ok,
         %Set{
           key: key,
           value: value
         }}

      ["SET", key, value, exp] ->
        parse_command_with_exp(
          %Set{
            key: key,
            value: value
          },
          exp
        )

      ["GETSET", key, value] ->
        {:ok,
         %Getset{
           key: key,
           value: value
         }}

      ["GETSET", key, value, exp] ->
        parse_command_with_exp(
          %Getset{
            key: key,
            value: value
          },
          exp
        )

      ["DEL", key] ->
        {:ok, %Del{key: key}}

      ["PING" | message] ->
        case message do
          [] ->
            {:ok, %Ping{message: "PONG"}}

          _ ->
            {:ok, %Ping{message: Enum.join(message, " ")}}
        end

      ["EXISTS", key] ->
        {:ok, %Exists{key: key}}

      ["TTL", key] ->
        {:ok, %Ttl{key: key}}

      ["RENAME", oldkey, newkey] ->
        {:ok,
         %Rename{
           oldkey: oldkey,
           newkey: newkey
         }}

      _ ->
        {:error, :unknown_command}
    end
  end

  defp parse_command_with_exp(command, exp) do
    case parse_exp(exp) do
      exp_time when is_integer(exp_time) ->
        {:ok, Map.put(command, :exp, exp_time)}

      :error ->
        {:error, :unknown_command}
    end
  end

  defp parse_exp(exp) do
    if Regex.match?(~r/^\d+$/, exp) do
      String.to_integer(exp)
    else
      :error
    end
  end
end
