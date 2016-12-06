defmodule Aoc2016.Day3 do
  @doc ~S"""
  Now that you can think clearly, you move deeper into the labyrinth of hallways
  and office furniture that makes up this part of Easter Bunny HQ. This must be
  a graphic design department; the walls are covered in specifications for
  triangles.

  Or are they?

  The design document gives the side lengths of each triangle it describes,
  but... 5 10 25? Some of these aren't triangles. You can't help but mark the
  impossible ones.

  In a valid triangle, the sum of any two sides must be larger than the
  remaining side. For example, the "triangle" given above is impossible, because
  5 + 10 is not larger than 25.

  In your puzzle input, how many of the listed triangles are possible?

  iex> Aoc2016.Day3.triangle_count("  1 2   3\n  1  2  2\n  4  3  2")
  2
  """
  def triangle_count(list_str) do
    list_str |> clean |> count
  end

  defp clean(list) do
    list
    |> String.split("\n")
    |> Enum.map(fn(line) ->
        line
        |> String.strip
        |> String.split(" ")
        |> Enum.filter(fn(x) -> x != "" end)
        |> Enum.map(&to_i/1)
      end)
  end

  defp count(list) do
    list
    |> Enum.map(&Enum.sort/1)
    |> Enum.filter(&triangle?/1)
    |> Enum.count
  end

  defp to_i(nr) do
    {i, _} = Integer.parse(nr)
    i
  end

  defp triangle?([a, b, c]), do: a + b > c

  @doc ~S"""
  Now that you've helpfully marked up their design documents, it occurs to you
  that triangles are specified in groups of three vertically. Each set of three
  numbers in a column specifies a triangle. Rows are unrelated.

  For example, given the following specification, numbers with the same hundreds
  digit would be part of the same triangle:

  101 301 501
  102 302 502
  103 303 503
  201 401 601
  202 402 602
  203 403 603

  In your puzzle input, and instead reading by columns, how many of the listed
  triangles are possible?

  iex> Aoc2016.Day3.v_triangle_count("1 2 3\n1 2 3\n 1 2 3\n4 5 6\n4 5 6\n4 5 6")
  6
  """
  def v_triangle_count(v_list_str) do
    v_list_str |> clean |> rotate |> count
  end

  defp rotate([[a1, b1, c1], [a2, b2, c2], [a3, b3, c3]]) do
      [[a1, a2, a3], [b1, b2, b3], [c1, c2, c3]]
  end
  defp rotate(list) do
    list
    |> Enum.chunk(3)
    |> Enum.map(&rotate/1)
    |> Enum.flat_map(fn(x) -> x end)
  end
end
