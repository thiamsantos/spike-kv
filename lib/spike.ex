defmodule Spike do
  use Application

  alias Spike.{Storage, Socket}
  alias Spike.Storage

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Spike.ServerSupervisor},
      {Socket, []},
      {Storage, [name: Storage]}
    ]

    opts = [strategy: :one_for_one, name: Spike.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
