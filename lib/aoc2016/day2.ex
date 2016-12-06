defmodule Aoc2016.Day2 do
  @keypad {{"1", "2", "3"}, {"4", "5", "6"}, {"7", "8", "9"}}

  @doc ~S"""
  You arrive at Easter Bunny Headquarters under cover of darkness. However, you
  left in such a rush that you forgot to use the bathroom! Fancy office
  buildings like this one usually have keypad locks on their bathrooms, so you
  search the front desk for the code.

  "In order to improve security," the document you find says, "bathroom codes
  will no longer be written down. Instead, please memorize and follow the
  procedure below to access the bathrooms."

  The document goes on to explain that each button to be pressed can be found by
  starting on the previous button and moving to adjacent buttons on the keypad:
  U moves up, D moves down, L moves left, and R moves right. Each line of
  instructions corresponds to one button, starting at the previous button (or,
  for the first line, the "5" button); press whatever button you're on at the
  end of each line. If a move doesn't lead to a button, ignore it.

  You can't hold it much longer, so you decide to figure out the code as you walk
  to the bathroom. You picture a keypad like this:

  1 2 3
  4 5 6
  7 8 9

  ## Suppose your instructions are:

    iex> Aoc2016.Day2.batchroom_code(["ULL", "RRDDD", "LURDL", "UUUUD"])
    "1985"
  """
  def batchroom_code(instructions) do
    instructions
    |> Enum.map_reduce({0, 0}, &code_point/2)
    |> to_code
  end

  def code_point(instruction, current) when is_bitstring(instruction) do
    next =
      instruction
      |> String.graphemes
      |> code_point(current)
    {next, next}
  end
  def code_point([], current), do: current
  def code_point([h | rest], current), do: code_point(rest, next(current, h))

  defp next({x, 0}, "U"), do: {x, 0}
  defp next({x, y}, "U"), do: {x, y - 1}
  defp next({x, 2}, "D"), do: {x, 2}
  defp next({x, y}, "D"), do: {x, y + 1}
  defp next({0, y}, "L"), do: {0, y}
  defp next({x, y}, "L"), do: {x - 1, y}
  defp next({2, y}, "R"), do: {2, y}
  defp next({x, y}, "R"), do: {x + 1, y}

  defp to_code({points, _}) do
    points
    |> Enum.map(fn({x, y}) -> @keypad |> elem(y) |> elem(x) end)
    |> Enum.join("")
  end
end
