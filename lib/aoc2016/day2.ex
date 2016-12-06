defmodule Aoc2016.Day2 do
  @keypad {
                {"1", "2", "3"},
                {"4", "5", "6"},
                {"7", "8", "9"}
          }

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
    |> to_code(@keypad)
  end

  def code_point(instruction, current) when is_bitstring(instruction) do
    next =
      instruction
      |> String.graphemes
      |> code_point(current)
    {next, next}
  end
  def code_point([], current), do: current
  def code_point([h | rest], current), do: code_point(rest, next(current, h, 2))

  defp next({x, 0}, "U", _), do: {x, 0}
  defp next({x, y}, "U", _), do: {x, y - 1}
  defp next({x, max}, "D", max), do: {x, max}
  defp next({x, y}, "D", _), do: {x, y + 1}
  defp next({0, y}, "L", _), do: {0, y}
  defp next({x, y}, "L", _), do: {x - 1, y}
  defp next({max, y}, "R", max), do: {max, y}
  defp next({x, y}, "R", _), do: {x + 1, y}

  defp to_code({points, _}, keypad) when is_list(points) do
    points
    |> Enum.map(&to_code(&1, keypad))
    |> Enum.join("")
  end
  defp to_code({x, y}, keypad), do: keypad |> elem(y) |> elem(x)

  @real_keypad {
                {nil, nil, "1", nil, nil},
                {nil, "2", "3", "4", nil},
                {"5", "6", "7", "9", "9"},
                {nil, "A", "B", "C", nil},
                {nil, nil, "D", nil, nil},
               }
  @doc ~S"""
  You finally arrive at the bathroom (it's a several minute walk from the lobby
  so visitors can behold the many fancy conference rooms and water coolers on
  this floor) and go to punch in the code. Much to your bladder's dismay, the
  keypad is not at all like you imagined it. Instead, you are confronted with
  the result of hundreds of man-hours of bathroom-keypad-design meetings:

      1
    2 3 4
  5 6 7 8 9
    A B C
      D

  ## You still start at "5" and stop when you're at an edge, but given the same
     instructions as above, the outcome is very different

    iex> Aoc2016.Day2.real_batchroom_code(["ULL", "RRDDD", "LURDL", "UUUUD"])
    "5DB3"
  """
  def real_batchroom_code(instructions) do
    instructions
    |> Enum.map_reduce({0, 2}, &real_code_point(&1, &2, @real_keypad))
    |> to_code(@real_keypad)
  end

  def real_code_point(instruction, current, keypad) when is_bitstring(instruction) do
    next =
      instruction
      |> String.graphemes
      |> real_code_point(current, keypad)
    {next, next}
  end
  def real_code_point([], current, keypad), do: current
  def real_code_point([h | rest], current, keypad) do
    candidate = next(current, h, 4)
    next_current = case to_code(candidate, keypad) do
      nil -> current
      _  -> candidate
    end

    real_code_point(rest, next_current, keypad)
  end
end
