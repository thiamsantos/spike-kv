defmodule Spike.Command do
  alias Spike.Request

  def run(%Request{storage: storage, now: now, command: command}) do
    GenServer.call(storage, {command, now})
  end
end
