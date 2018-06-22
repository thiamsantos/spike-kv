defmodule Spike.Parser do
  alias Spike.Command.{Get, Set, Del, Ping, Exists, Ttl, Rename, Getset, Error, Keys}

  def parse(command) do
    case String.split(command) do
      ["GET", key] ->
        %Get{key: key}

      ["SET", key, value] ->
        %Set{key: key, value: value}

      ["SET", key, value, exp] ->
        parse_command_with_exp(%Set{key: key, value: value}, exp)

      ["GETSET", key, value] ->
        %Getset{key: key, value: value}

      ["GETSET", key, value, exp] ->
        parse_command_with_exp(%Getset{key: key, value: value}, exp)

      ["DEL", key] ->
        %Del{key: key}

      ["PING" | message] ->
        case message do
          [] ->
            %Ping{message: "PONG"}

          _ ->
            %Ping{message: Enum.join(message, " ")}
        end

      ["EXISTS", key] ->
        %Exists{key: key}

      ["TTL", key] ->
        %Ttl{key: key}

      ["RENAME", oldkey, newkey] ->
        %Rename{oldkey: oldkey, newkey: newkey}

      ["KEYS"] ->
        %Keys{}

      _ ->
        %Error{message: :unknown_command}
    end
  end

  defp parse_command_with_exp(command, exp) do
    case parse_exp(exp) do
      exp_time when is_integer(exp_time) ->
        Map.put(command, :exp, exp_time)

      :error ->
        %Error{message: :unknown_command}
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
