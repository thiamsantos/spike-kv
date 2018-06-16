defmodule Spike.Runner do
  alias Spike.{Command, Storage, Response}

  @current_time Application.get_env(:spike, :current_time)

  def run({:ok, command}) do
    Command.run(command)
    |> Response.parse()
  end

  def run({:error, token}) when is_atom(token) do
    Response.parse({:error, token})
  end
end
