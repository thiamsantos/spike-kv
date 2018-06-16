defprotocol Spike.Command do
  def run(command)
end

defimpl Spike.Command, for: Spike.Command.Del do
  def run(%Spike.Command.Del{storage: storage, current_time: current_time, key: key}) do
    GenServer.call(storage, {:del, current_time, key})
  end
end

defimpl Spike.Command, for: Spike.Command.Exists do
  def run(%Spike.Command.Exists{storage: storage, current_time: current_time, key: key}) do
    {:ok, GenServer.call(storage, {:exists?, current_time, key})}
  end
end

defimpl Spike.Command, for: Spike.Command.Get do
  def run(%Spike.Command.Get{storage: storage, current_time: current_time, key: key}) do
    {:ok, GenServer.call(storage, {:get, current_time, key})}
  end
end

defimpl Spike.Command, for: Spike.Command.Set do
  def run(%Spike.Command.Set{
        storage: storage,
        current_time: current_time,
        key: key,
        value: value,
        expiration: expiration
      })
      when not is_nil(expiration) do
    GenServer.call(storage, {:set, current_time, key, value, expiration})
  end

  def run(%Spike.Command.Set{storage: storage, current_time: current_time, key: key, value: value}) do
    GenServer.call(storage, {:set, current_time, key, value})
  end
end

defimpl Spike.Command, for: Spike.Command.Getset do
  def run(%Spike.Command.Getset{
        storage: storage,
        current_time: current_time,
        key: key,
        value: value,
        expiration: expiration
      })
      when not is_nil(expiration) do
    {:ok, GenServer.call(storage, {:getset, current_time, key, value, expiration})}
  end

  def run(%Spike.Command.Getset{
        storage: storage,
        current_time: current_time,
        key: key,
        value: value
      }) do
    {:ok, GenServer.call(storage, {:getset, current_time, key, value})}
  end
end

defimpl Spike.Command, for: Spike.Command.Ttl do
  def run(%Spike.Command.Ttl{storage: storage, current_time: current_time, key: key}) do
    GenServer.call(storage, {:ttl, current_time, key})
  end
end

defimpl Spike.Command, for: Spike.Command.Rename do
  def run(%Spike.Command.Rename{
        storage: storage,
        current_time: current_time,
        oldkey: oldkey,
        newkey: newkey
      }) do
    GenServer.call(storage, {:rename, current_time, oldkey, newkey})
  end
end

defimpl Spike.Command, for: Spike.Command.Ping do
  def run(%Spike.Command.Ping{storage: storage, message: message}) do
    GenServer.call(storage, {:ping, message})
  end
end
