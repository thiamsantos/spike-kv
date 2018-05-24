defmodule Spike.Command do
  alias Spike.Storage

  def parse(command) do
    case String.split(command) do
      ["GET", key] -> {:ok, %{fun: :get, args: [key]}}
      ["SET", key, value] -> {:ok, %{fun: :set, args: [key, value]}}
      ["DEL", key] -> {:ok, %{fun: :del, args: [key]}}
      _ -> {:error, :unknown_command}
    end
  end

  def run({:ok, %{fun: fun, args: args}}) do
    apply(Storage, fun, [Storage | args])
    |> handle_storage_response()
    |> put_line_breaks()
  end

  def run({:error, :unknown_command}) do
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
