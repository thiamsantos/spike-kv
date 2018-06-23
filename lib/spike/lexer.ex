defmodule Spike.Lexer do
  alias Spike.Bag.{EmptyBag, OrdinaryBag, StringBag}

  def run(command) do
    command
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index()
    |> parse_command()
  end

  defp parse_command(chars) do
    parse_command(chars, [], List.first(chars), %EmptyBag{})
  end

  defp parse_command(_chars, acc, nil, %EmptyBag{}) do
    Enum.reverse(acc)
  end

  defp parse_command(chars, acc, nil, %OrdinaryBag{content: content}) do
    parse_command(chars, [get_possible_integer_arg(content) | acc], nil, %EmptyBag{})
  end

  defp parse_command(chars, acc, {" ", index}, %EmptyBag{} = bag) do
    parse_command(chars, acc, Enum.at(chars, index + 1), bag)
  end

  defp parse_command(chars, acc, {"\"", index}, %EmptyBag{}) do
    parse_command(chars, acc, Enum.at(chars, index + 1), %StringBag{})
  end

  defp parse_command(chars, acc, {item, index}, %EmptyBag{}) do
    parse_command(chars, acc, Enum.at(chars, index + 1), %OrdinaryBag{content: item})
  end

  defp parse_command(chars, acc, {"\"", index}, %StringBag{content: content}) do
    parse_command(chars, [content | acc], Enum.at(chars, index + 1), %EmptyBag{})
  end

  defp parse_command(chars, acc, {item, index}, %StringBag{content: content}) do
    parse_command(chars, acc, Enum.at(chars, index + 1), %StringBag{content: content <> item})
  end

  defp parse_command(chars, acc, {" ", index}, %OrdinaryBag{content: content}) do
    parse_command(
      chars,
      [get_possible_integer_arg(content) | acc],
      Enum.at(chars, index + 1),
      %EmptyBag{}
    )
  end

  defp parse_command(chars, acc, {item, index}, %OrdinaryBag{content: content}) do
    parse_command(chars, acc, Enum.at(chars, index + 1), %OrdinaryBag{content: content <> item})
  end

  defp get_possible_integer_arg(arg) do
    if Regex.match?(~r/^\d+$/, arg) do
      String.to_integer(arg)
    else
      arg
    end
  end
end
