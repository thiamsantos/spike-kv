defmodule Spike.Command do
  alias Spike.Storage

  def parse(command) do
    case String.split(command) do
      ["GET", key] -> {:ok, {:get, key}}
      ["SET", key, value] -> {:ok, {:set, key, value}}
      ["DEL", key] -> {:ok, {:del, key}}
      _ -> {:error, {:unknown_command}}
    end
  end

  def run({:ok, {:get, key}}) do
    Storage.get(Storage, key)
    |> handle_storage_response()
    |> put_line_breaks()
  end

  def run({:ok, {:set, key, value}}) do
    Storage.set(Storage, key, value)
    |> handle_storage_response()
    |> put_line_breaks()
  end

  def run({:ok, {:del, key}}) do
    Storage.del(Storage, key)
    |> handle_storage_response()
    |> put_line_breaks()
  end

  def run({:error, {:unknown_command}}) do
    "unknown COMMAND"
    |> put_line_breaks()
  end

  defp handle_storage_response({:ok, nil}) do
    "NOT FOUND"
  end

  defp handle_storage_response({:ok, value}) do
    put_line_breaks("#{value}") <> "OK"
  end

  defp handle_storage_response(:ok) do
    "OK"
  end

  defp put_line_breaks(msg) do
    msg <> "\r\n"
  end
end
