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

  defp calc_distance({x, y, _}), do: abs(x) + abs(y)
end
