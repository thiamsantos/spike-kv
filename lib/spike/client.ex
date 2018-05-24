defmodule Spike.Client do
  alias Spike.{Command, Storage}

  def run({:ok, %Command{fun: fun, args: args}}) do
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
