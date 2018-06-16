defmodule Spike.Runner do
  alias Spike.{Command, Request, Response}

  def run({:ok, command}) do
    command
    |> Request.create()
    |> Command.run()
    |> Response.parse()
  end

  def run({:error, token}) when is_atom(token) do
    Response.parse({:error, token})
  end
end
