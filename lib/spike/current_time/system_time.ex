defmodule Spike.CurrentTime.SystemTime do
  @behaviour Spike.CurrentTime

  def get_timestamp do
    :os.system_time(:seconds)
  end
end
