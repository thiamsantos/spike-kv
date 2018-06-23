defmodule Spike.Lexer do
  alias Spike.Bag.{EmptyBag, OrdinaryBag, StringBag}

  def run(command) do
    command
    |> cleanup()
    |> analyze()
  end

  defp cleanup(command) do
    command
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index()
  end

  defp analyze(chars) do
    analyze(chars, [], List.first(chars), %EmptyBag{})
  end

  defp analyze(_chars, acc, nil, %EmptyBag{}) do
    Enum.reverse(acc)
  end

  defp analyze(chars, acc, nil, %OrdinaryBag{content: content}) do
    analyze(chars, [get_possible_integer_arg(content) | acc], nil, %EmptyBag{})
  end

  defp analyze(chars, acc, {" ", index}, %EmptyBag{} = bag) do
    analyze(chars, acc, next_item(chars, index), bag)
  end

  defp analyze(chars, acc, {"\"", index}, %EmptyBag{}) do
    analyze(chars, acc, next_item(chars, index), %StringBag{})
  end

  defp analyze(chars, acc, {item, index}, %EmptyBag{}) do
    analyze(chars, acc, next_item(chars, index), %OrdinaryBag{content: item})
  end

  defp analyze(chars, acc, {"\"", index}, %StringBag{content: content}) do
    analyze(chars, [content | acc], next_item(chars, index), %EmptyBag{})
  end

  defp analyze(chars, acc, {item, index}, %StringBag{content: content}) do
    analyze(chars, acc, next_item(chars, index), %StringBag{content: content <> item})
  end

  defp analyze(chars, acc, {" ", index}, %OrdinaryBag{content: content}) do
    analyze(
      chars,
      [get_possible_integer_arg(content) | acc],
      next_item(chars, index),
      %EmptyBag{}
    )
  end

  defp analyze(chars, acc, {item, index}, %OrdinaryBag{content: content}) do
    analyze(chars, acc, Enum.at(chars, index + 1), %OrdinaryBag{content: content <> item})
  end

  defp next_item(chars, index) do
    Enum.at(chars, index + 1)
  end

  defp get_possible_integer_arg(arg) do
    if Regex.match?(~r/^\d+$/, arg) do
      String.to_integer(arg)
    else
      arg
    end
  end
end
