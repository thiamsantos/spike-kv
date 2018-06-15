defmodule Spike.Runner do
  alias Spike.{Command, Client, Storage}

  @current_time Application.get_env(:spike, :current_time)

  def run({:ok, %Command{fun: fun, args: args}}) do
    apply(Client, fun, [Storage | [@current_time.get_timestamp() | args]])
    |> handle_storage_response()
    |> put_line_breaks()
  end

  def run({:error, token}) when is_atom(token) do
    token
    |> error_token()
    |> error_response()
    |> put_line_breaks()
  end

  defp handle_storage_response({:ok, value}) when is_boolean(value) do
    value
    |> parse_boolean()
    |> success_response()
  end

  defp handle_storage_response({:ok, value}) when is_integer(value) do
    value
    |> integer_reply()
    |> success_response()
  end

  defp handle_storage_response({:ok, value}) do
    value
    |> parse_text_message()
    |> success_response()
  end

  defp handle_storage_response(:ok) do
    success_response("")
  end

  defp handle_storage_response({:error, value}) when is_integer(value) do
    value
    |> integer_reply()
    |> error_response()
  end

  defp handle_storage_response(:error) do
    error_response()
  end

  defp parse_text_message(nil) do
    "$0"
  end

  defp parse_text_message(content) do
    "$#{String.length(content)} #{content}"
  end

  defp error_token(atom) do
    atom
    |> Atom.to_string()
    |> String.upcase()
    |> tokenize_message()
  end

  defp integer_reply(num) do
    "+#{num}"
  end

  defp tokenize_message(message), do: ":" <> message

  defp success_response(""), do: ":OK"

  defp success_response(content), do: ":OK " <> content

  defp error_response, do: ":ERROR"
  defp error_response(content), do: ":ERROR " <> content

  defp put_line_breaks(msg), do: msg <> "\r\n"

  defp parse_boolean(true), do: "=1"
  defp parse_boolean(false), do: "=0"
end
