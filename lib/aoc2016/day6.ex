defmodule Aoc2016.Day6 do
  @doc ~S"""
  Something is jamming your communications with Santa. Fortunately, your signal
  is only partially jammed, and protocol in situations like this is to switch to
  a simple repetition code to get the message through.

  In this model, the same message is sent repeatedly. You've recorded the
  repeating message signal (your puzzle input), but the data seems quite
  corrupted - almost too badly to recover. Almost.

  All you need to do is figure out which character is most frequent for each
  position. For example, suppose you had recorded the following messages:

  eedadn
  drvtee
  eandsr
  raavrd
  atevrs
  tsrnev
  sdttsa
  rasrtv
  nssdts
  ntnada
  svetve
  tesnvt
  vntsnd
  vrdear
  dvrsen
  enarar

  The most common character in the first column is e; in the second, a; in the
  third, s, and so on. Combining these characters returns the error-corrected
  message, easter.

  iex> Aoc2016.Day6.decode("eedadn\ndrvtee\neandsr\nraavrd\natevrs\ntsrnev\nsdttsa\nrasrtv\nnssdts\nntnada\nsvetve\ntesnvt\nvntsnd\nvrdear\ndvrsen\nenarar")
  "easter"

  iex> Aoc2016.Day6.decode("my\nm")
  "my"
  """
  def decode(messages) do
    do_decode(messages, &max_occurence/1)
  end

  defp do_decode(messages, mapping_func) do
    messages
    |> String.split("\n")
    |> rotate([])
    |> Enum.map(mapping_func)
    |> Enum.join("")
  end

  defp rotate([], rotated), do: rotated
  defp rotate([message | rest] = messages, rotated) do
    new_rotated = rotated |> rotate_msg(message)
    rotate(rest, new_rotated)
  end
  defp rotate_msg(rotated, message) do
    {new_rotated, _} =
      message
      |> String.graphemes
      |> Enum.map_reduce(0, fn(val, i) -> {add(Enum.at(rotated, i), val), i + 1} end)

    rotated_length = length(rotated)
    new_rotated_length = length(new_rotated)
    case new_rotated_length < rotated_length do
      true -> new_rotated ++ Enum.slice(rotated, new_rotated_length, rotated_length)
      _ -> new_rotated
    end
  end

  defp add(nil, val), do: [val]
  defp add(list, val), do: [val | list]

  defp max_occurence(chars) do
    chars
    |> Enum.group_by(&Base.encode16/1)
    |> Dict.values
    |> Enum.max_by(&length/1)
    |> Enum.at(0)
  end

  @doc ~S"""
  Of course, that would be the message - if you hadn't agreed to use a modified
  repetition code instead.

  In this modified code, the sender instead transmits what looks like random
  data, but for each character, the character they actually want to send is
  slightly less likely than the others. Even after signal-jamming noise, you can
  look at the letter distributions in each column and choose the least common
  letter to reconstruct the original message.

  In the above example, the least common character in the first column is a; in
  the second, d, and so on. Repeating this process for the remaining characters
  produces the original message, advent.

  iex> Aoc2016.Day6.decode2("eedadn\ndrvtee\neandsr\nraavrd\natevrs\ntsrnev\nsdttsa\nrasrtv\nnssdts\nntnada\nsvetve\ntesnvt\nvntsnd\nvrdear\ndvrsen\nenarar")
  "advent"
  """
  def decode2(messages) do
    do_decode(messages, &min_occurence/1)
  end

  defp min_occurence(chars) do
    chars
    |> Enum.group_by(&Base.encode16/1)
    |> Dict.values
    |> Enum.min_by(&length/1)
    |> Enum.at(0)
  end
end
