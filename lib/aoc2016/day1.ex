defmodule Aoc2016.Day1 do
  @init_possition {0, 0, :N}

  @doc ~S"""
  # Part one

  You're airdropped near Easter Bunny Headquarters in a city somewhere. "Near",
  time to work them out further.

  The Document indicates that you should start at the given coordinates (where
  you just landed) and face North. Then, follow the provided sequence: either
  turn left (L) or right (R) 90 degrees, then walk forward the given number of
  blocks, ending at a new intersection.

  There's no time to follow such ridiculous instructions on foot, though, so you
  take a moment and work out the destination. Given that you can only walk on
  the street grid of the city, how far is the shortest path to the destination?

  ## For example:

    iex> Aoc2016.Day1.distance("R2, L3")
    5

    iex> Aoc2016.Day1.distance("R2, R2, R2")
    2

    iex> Aoc2016.Day1.distance("R5, L5, R5, R3")
    12
  """
  def distance(instructions) do
    instructions
    |> steps
    |> Enum.reduce(@init_possition, &move/2)
    |> calc_distance
  end

  defp steps(instructions), do: String.split(instructions, ", ")

  defp move("R" <> steps, {x, y, :N}), do: {x + to_i(steps), y, :E}
  defp move("R" <> steps, {x, y, :E}), do: {x, y - to_i(steps), :S}
  defp move("R" <> steps, {x, y, :S}), do: {x - to_i(steps), y, :W}
  defp move("R" <> steps, {x, y, :W}), do: {x, y + to_i(steps), :N}

  defp move("L" <> steps, {x, y, :N}), do: {x - to_i(steps), y, :W}
  defp move("L" <> steps, {x, y, :E}), do: {x, y + to_i(steps), :N}
  defp move("L" <> steps, {x, y, :S}), do: {x + to_i(steps), y, :E}
  defp move("L" <> steps, {x, y, :W}), do: {x, y - to_i(steps), :S}

  defp to_i(nr) do
    {val, _} = Integer.parse(nr)
    val
  end

  defp calc_distance({x, y, _}), do: calc_distance({x, y})
  defp calc_distance({x, y}), do: abs(x) + abs(y)
  defp calc_distance(_), do: :error

  @doc ~S"""
  # Part two

  Then, you notice the instructions continue on the back of the Recruiting
  Document. Easter Bunny HQ is actually at the first location you visit twice.

  ## For example:

    iex> Aoc2016.Day1.hq_distance("R8, R4, R4, R8")
    4

    iex> Aoc2016.Day1.hq_distance("R4, R3, L1, L2, L3")
    5

    iex> Aoc2016.Day1.hq_distance("R4, L2, L2, L3, R1, R2")
    2

    iex> Aoc2016.Day1.hq_distance("R3, L4, R1, R1, R2, L4")
    6
  """
  def hq_distance(instructions) do
    {sections, _} =
      instructions
      |> steps
      |> Enum.map_reduce(@init_possition, fn(step, {x1, y1, _} = current_possition) -> {1, 2}
          {x2, y2, _} = next_possition = move(step, current_possition)
          {{x1, y1, x2, y2}, next_possition}
        end)

    find_crossing_point([], sections)
    |> calc_distance
  end

  defp find_crossing_point(_, [_ | []]), do: nil
  defp find_crossing_point(sections, [f | [s | rest]]) do
    case crossing_point(sections, s) do
      nil -> find_crossing_point([f | sections], [s | rest])
      point -> point
    end
  end

  defp crossing_point(sections, section) when is_list(sections) do
    sections
    |> Enum.find(&crossing?(&1, section))
    |> crossing_point(section)
  end

  defp crossing_point(nil, _), do: nil
  defp crossing_point({_, y, _, y}, {x, _, x, _}), do: {x, y}
  defp crossing_point(e1, e2), do: crossing_point(e2, e1)

  defp crossing?({x1, y, x2, y}, {x, y1, x, y2}) do
    {xx1, xx2} = {x - x1, x - x2}
    {yy1, yy2} = {y - y1, y - y2}

    (xx1 <= 0 && xx2 >= 0 || xx1 >= 0 && xx2 <= 0) &&
      (yy1 <= 0 && yy2 >= 0 || yy1 >= 0 && yy2 <= 0)
  end
  defp crossing?({x, _, x, _} = s1, {_, y, _, y} = s2), do: crossing?(s2, s1)
  defp crossing?(_, _), do: false
end
