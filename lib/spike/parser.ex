defmodule Spike.Parser do
  alias Spike.Command.{Get, Set, Del, Ping, Exists, Ttl, Rename, Getset, Error, Keys}

  def parse(command) do
    case command do
      ["GET", key] ->
        %Get{key: key}

      ["SET", key, value] ->
        %Set{key: key, value: value}

      ["SET", key, value, exp] when is_integer(exp) ->
        %Set{key: key, value: value, exp: exp}

      ["GETSET", key, value] ->
        %Getset{key: key, value: value}

      ["GETSET", key, value, exp] when is_integer(exp) ->
        %Getset{key: key, value: value, exp: exp}

      ["DEL", key] ->
        %Del{key: key}

      ["PING"] ->
        %Ping{message: "PONG"}

      ["PING", message] ->
        %Ping{message: message}

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
end
