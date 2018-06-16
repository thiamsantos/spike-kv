defmodule Spike.Request do
  alias Spike.Storage

  @current_time Application.get_env(:spike, :current_time)

  @enforce_keys [:storage, :now, :command]
  defstruct [:storage, :now, :command]

  def create(command) do
    %__MODULE__{storage: Storage, now: @current_time.get_timestamp(), command: command}
  end
end
