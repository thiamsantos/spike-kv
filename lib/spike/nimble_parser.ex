defmodule Spike.NimbleParser do
  import NimbleParsec

  keywords = [:getset, :set, :get, :keys, :del, :flush, :ping, :exists, :rename, :ttl]

  commands =
    Enum.map(keywords, fn key ->
      string_key = to_string(key)

      replace(
        choice([string(String.upcase(string_key)), string(String.downcase(string_key))]),
        key
      )
    end)

  commands_pattern = choice(commands)

  separator = ignore(string(" "))

  arg =
    choice([
      integer(min: 1),
      ignore(string("\""))
      |> repeat(choice([utf8_string([?A..?z], min: 1), string(" ")]))
      |> ignore(string("\""))
      |> reduce({Enum, :join, [""]}),
      repeat(utf8_string([?A..?z], min: 1))
    ])

  eof =
    ignore(string("\r\n"))
    |> eos()

  args = times(concat(separator, arg), min: 1)
  pattern = commands_pattern |> concat(optional(args)) |> concat(eof)

  defparsec(:parse, pattern)
end
