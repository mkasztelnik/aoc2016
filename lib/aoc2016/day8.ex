defmodule Aoc2016.Day8 do
  @doc ~S"""
  You come across a door implementing what you can only assume is an
  implementation of two-factor authentication after a long game of requirements
  telephone.

  To get past the door, you first swipe a keycard (no problem; there was one on
  a nearby desk). Then, it displays a code on a little screen, and you type that
  code on a keypad. Then, presumably, the door unlocks.

  Unfortunately, the screen has been smashed. After a few minutes, you've taken
  everything apart and figured out how it works. Now you just have to work out
  what the screen would have displayed.

  The magnetic strip on the card you swiped encodes a series of instructions for
  the screen; these instructions are your puzzle input. The screen is 50 pixels
  wide and 6 pixels tall, all of which start off, and is capable of three
  somewhat peculiar operations:

    - rect AxB turns on all of the pixels in a rectangle at the top-left of the
      screen which is A wide and B tall.

    - rotate row y=A by B shifts all of the pixels in row A (0 is the top row) right
      by B pixels. Pixels that would fall off the right end appear at the left end
      of the row.

    - rotate column x=A by B shifts all of the pixels in column A (0 is the left
      column) down by B pixels. Pixels that would fall off the bottom appear at the
      top of the column.

  For example, here is a simple sequence on a smaller screen:

  rect 3x2 creates a small rectangle in the top-left corner:

  ###....
  ###....
  .......

  rotate column x=1 by 1 rotates the second column down by one pixel:

  #.#....
  ###....
  .#.....

  rotate row y=0 by 4 rotates the top row right by four pixels:

  ....#.#
  ###....
  .#.....

  rotate column x=1 by 1 again rotates the second column down by one pixel,
  causing the bottom pixel to wrap back to the top:

  .#..#.#
  #.#....
  .#.....

  As you can see, this display technology is extremely powerful, and will soon
  dominate the tiny-code-displaying-screen market. That's what the advertisement
  on the back of the display tries to convince you, anyway.

  There seems to be an intermediate check of the voltage used by the display:
  after you swipe your card, if the screen did work, how many pixels should be
  lit?

  iex> Aoc2016.Day8.pixels_count(7, 3, [
  ...>  "rect 3x2", "rotate column x=1 by 1",
  ...>  "rotate row y=0 by 4", "rotate column x=1 by 1"])
  6
  """
  def pixels_count(width, height, instructions) do
    display(width, height, instructions)
    |> Enum.map(fn(row) -> Enum.count(row, &(&1 == "#")) end)
    |> Enum.reduce(0, &(&1 + &2))
  end

  @doc ~S"""
  iex> Aoc2016.Day8.display(7, 3, [
  ...>  "rect 3x2", "rotate column x=1 by 1",
  ...>  "rotate row y=0 by 4", "rotate column x=1 by 1"])
  [
   [".", "#", ".", ".", "#", ".", "#"],
   ["#", ".", "#", ".", ".", ".", "."],
   [".", "#", ".", ".", ".", ".", "."]
  ]
  """
  def display(width, height, instructions) do
    gen_display(width, height)
    |> do_display(instructions)
    |> to_list
  end

  defp do_display(display, []), do: display
  defp do_display(display, [instruction | rest]) do
    display
    |> perform(instruction)
    |> do_display(rest)
  end

  defp perform(display, "rect " <> instruction) do
    %{"w" => w, "h" => h} = Regex.named_captures(~r/(?<w>\d+)x(?<h>\d+)/, instruction)
    fill(display, String.to_integer(w), String.to_integer(h))
  end
  defp perform(display, "rotate column " <> instruction) do
    %{"col" => col, "by" => by} =
      Regex.named_captures(~r/x=(?<col>\d+) by (?<by>\d+)/, instruction)
    rotate_col(display, String.to_integer(col), String.to_integer(by))
  end
  defp perform(display, "rotate row " <> instruction) do
    %{"row" => row, "by" => by} =
      Regex.named_captures(~r/y=(?<row>\d+) by (?<by>\d+)/, instruction)
    rotate_row(display, String.to_integer(row), String.to_integer(by))
  end

  defp fill(%{pixels: pixels, width: width, height: height} = display, w, h)
  when w <= width and h <= height do
    filled = (for i <- 0..(w - 1), j <- 0..(h - 1), do: {i, j})
             |> Enum.map(&({&1, "#"}))
             |> Enum.into(%{})
    %{display | pixels: Map.merge(pixels, filled)}
  end

  defp rotate_col(%{pixels: pixels, width: width, height: height} = display, i, by)
  when i < width do
    rotated = col(display, i)
              |> Enum.map_reduce(0, fn(x, j) ->
                  {{{i, rem(j + by, height)}, x}, j + 1}
                end)
              |> elem(0)
              |> Enum.into(%{})
    %{display | pixels: Map.merge(pixels, rotated)}
  end

  defp rotate_row(%{pixels: pixels, width: width, height: height} = display, j, by)
  when j < height do
    rotated = row(display, j)
              |> Enum.map_reduce(0, fn(x, i) ->
                  {{{rem(i + by, width), j}, x}, i + 1}
                end)
              |> elem(0)
              |> Enum.into(%{})
    %{display | pixels: Map.merge(pixels, rotated)}
  end

  defp gen_display(width, height) do
    pixels = (for i <- 0..(width - 1), j <- 0..(height - 1), do:  {i, j})
             |> Enum.map(&({&1, "."}))
             |> Enum.into(%{})

    %{pixels: pixels, width: width, height: height}
  end

  defp row(%{pixels: pixels, width: width, height: height}, j) when j < height do
    for i <- 0..(width - 1), do: pixels[{i, j}]
  end

  defp col(%{pixels: pixels, width: width, height: height}, i) when i < width do
    for j <- 0..(height - 1), do: pixels[{i, j}]
  end

  defp to_list(%{pixels: pixels, width: width, height: height}) do
    for j <- 0..(height - 1) do
      for i <- 0..(width - 1), do: pixels[{i, j}]
    end
  end
end
