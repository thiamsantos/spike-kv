defmodule Spike.Parser do
  alias Spike.Storage
  alias Spike.Command.{Get, Set, Del, Ping, Exists, Ttl, Rename, Getset}

  @current_time Application.get_env(:spike, :current_time)

  def parse(command) do
    case String.split(command) do
      ["GET", key] ->
        {:ok, %Get{storage: Storage, current_time: @current_time.get_timestamp(), key: key}}

      ["SET", key, value] ->
        {:ok,
         %Set{
           storage: Storage,
           current_time: @current_time.get_timestamp(),
           key: key,
           value: value
         }}

      ["SET", key, value, expiration] ->
        parse_command_with_expiration(
          %Set{
            storage: Storage,
            current_time: @current_time.get_timestamp(),
            key: key,
            value: value
          },
          expiration
        )

      ["GETSET", key, value] ->
        {:ok,
         %Getset{
           storage: Storage,
           current_time: @current_time.get_timestamp(),
           key: key,
           value: value
         }}

      ["GETSET", key, value, expiration] ->
        parse_command_with_expiration(
          %Getset{
            storage: Storage,
            current_time: @current_time.get_timestamp(),
            key: key,
            value: value
          },
          expiration
        )

      ["DEL", key] ->
        {:ok, %Del{storage: Storage, current_time: @current_time.get_timestamp(), key: key}}

      ["PING" | message] ->
        case message do
          [] ->
            {:ok, %Ping{storage: Storage, message: "PONG"}}

          _ ->
            {:ok, %Ping{storage: Storage, message: Enum.join(message, " ")}}
        end

      ["EXISTS", key] ->
        {:ok, %Exists{storage: Storage, current_time: @current_time.get_timestamp(), key: key}}

      ["TTL", key] ->
        {:ok, %Ttl{storage: Storage, current_time: @current_time.get_timestamp(), key: key}}

      ["RENAME", oldkey, newkey] ->
        {:ok,
         %Rename{
           storage: Storage,
           current_time: @current_time.get_timestamp(),
           oldkey: oldkey,
           newkey: newkey
         }}

      _ ->
        {:error, :unknown_command}
    end
  end

  defp parse_command_with_expiration(command, expiration) do
    case parse_expiration(expiration) do
      expiration_time when is_integer(expiration_time) ->
        {:ok, Map.put(command, :expiration, expiration_time)}

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
end
