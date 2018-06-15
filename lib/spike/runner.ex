defmodule Spike.Runner do
  alias Spike.{Command, Client, Storage, Response}

  @current_time Application.get_env(:spike, :current_time)

  def run({:ok, %Command{fun: fun, args: args}}) do
    apply(Client, fun, [Storage | [@current_time.get_timestamp() | args]])
    |> Response.parse()
  end

  def run({:error, token}) when is_atom(token) do
    Response.parse({:error, token})
  end
end
