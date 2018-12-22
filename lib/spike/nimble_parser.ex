defmodule Spike.NimbleParser do
  import NimbleParsec

  commands =
    utf8_string([?A..?z], min: 1)
    |> map({String, :upcase, []})

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
  pattern = commands |> concat(optional(args)) |> concat(eof)

  defparsec(:parse, pattern)
end
