defmodule Aoc2016.Day9 do
  @doc ~S"""
  Wandering around a secure area, you come across a datalink port to a new part
  of the network. After briefly scanning it for interesting files, you find one
  file in particular that catches your attention. It's compressed with an
  experimental format, but fortunately, the documentation for the format is
  nearby.

  The format compresses a sequence of characters. Whitespace is ignored. To
  indicate that some sequence should be repeated, a marker is added to the file,
  like (10x2). To decompress this marker, take the subsequent 10 characters and
  repeat them 2 times. Then, continue reading the file after the repeated data.
  The marker itself is not included in the decompressed output.

  If parentheses or other characters appear within the data referenced by a
  marker, that's okay - treat it like normal data, not a marker, and then resume
  looking for markers after the decompressed section.

  For example:

    - ADVENT contains no markers and decompresses to itself with no changes,
      resulting in a decompressed length of 6.

    - A(1x5)BC repeats only the B a total of 5 times, becoming ABBBBBC for a
      decompressed length of 7.

    - (3x3)XYZ becomes XYZXYZXYZ for a decompressed length of 9.

    - A(2x2)BCD(2x2)EFG doubles the BC and EF, becoming ABCBCDEFEFG for a
      decompressed length of 11.

    - (6x1)(1x3)A simply becomes (1x3)A - the (1x3) looks like a marker, but because
      it's within a data section of another marker, it is not treated any
      differently from the A that comes after it. It has a decompressed length of 6.

    - X(8x2)(3x3)ABCY becomes X(3x3)ABC(3x3)ABCY (for a decompressed length of 18),
      because the decompressed data from the (8x2) marker (the (3x3)ABC) is skipped
      and not processed further.

  iex> Aoc2016.Day9.extend("ADVENT")
  "ADVENT"

  iex> Aoc2016.Day9.extend("A(1x5)BC")
  "ABBBBBC"

  iex> Aoc2016.Day9.extend("(3x3)XYZ")
  "XYZXYZXYZ"

  iex> Aoc2016.Day9.extend("A(2x2)BCD(2x2)EFG")
  "ABCBCDEFEFG"

  iex> Aoc2016.Day9.extend("(6x1)(1x3)A")
  "(1x3)A"

  iex> Aoc2016.Day9.extend("X(8x2)(3x3)ABCY")
  "X(3x3)ABC(3x3)ABCY"
  """
  def extend(code) do
    code
    |> String.graphemes
    |> do_extend([])
  end

  defp do_extend(["(" | t], result) do
    %{"n" => n, "subsequent" => subsequent, "rest" => rest} = parse(t)

    rest
    |> String.graphemes
    |> do_extend([String.duplicate(subsequent, String.to_integer(n)) | result])
  end
  defp do_extend([], result), do: result |> Enum.reverse() |> Enum.join("")
  defp do_extend([char | rest], result), do: do_extend(rest, [char | result])

  defp parse(tab) do
    rest = Enum.join(tab, "")
    %{"size" => size, "n" => n, "rest" => rest} =
      Regex.named_captures(~r/(?<size>\d+)x(?<n>\d+)\)(?<rest>.*)/, rest)
    %{"subsequent" => subsequent, "rest" => rest} =
      Regex.named_captures(~r/(?<subsequent>.{0,#{size}})(?<rest>.*)/, rest)

    %{"n" => n, "subsequent" => subsequent, "rest" => rest}
  end

  @doc ~S"""
  Apparently, the file actually uses version two of the format.

  In version two, the only difference is that markers within decompressed data
  are decompressed. This, the documentation explains, provides much more
  substantial compression capabilities, allowing many-gigabyte files to be
  stored in only a few kilobytes.

  For example:

    - (3x3)XYZ still becomes XYZXYZXYZ, as the decompressed section contains no
      markers.

    - X(8x2)(3x3)ABCY becomes XABCABCABCABCABCABCY, because the decompressed data
      from the (8x2) marker is then further decompressed, thus triggering the (3x3)
      marker twice for a total of six ABC sequences.

    - (27x12)(20x12)(13x14)(7x10)(1x12)A decompresses into a string of A repeated
      241920 times.

    - (25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN becomes 445
      characters long.

  Unfortunately, the computer you brought probably doesn't have enough memory to
  actually decompress the file; you'll have to come up with another way to get
  its decompressed length.

  What is the decompressed length of the file using this improved format?

  iex> Aoc2016.Day9.extended_length("(3x3)XYZ")
  9

  iex> Aoc2016.Day9.extended_length("X(8x2)(3x3)ABCY")
  20

  iex> Aoc2016.Day9.extended_length("(27x12)(20x12)(13x14)(7x10)(1x12)A")
  241920

  iex> Aoc2016.Day9.extended_length("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN")
  445
  """
  def extended_length(code) do
    code
    |> String.graphemes
    |> calculate_length(0)
  end

  defp calculate_length(["(" | t], code_size) do
    %{"n" => n, "subsequent" => subsequent, "rest" => rest} = parse(t)

    rest
    |> String.graphemes
    |> calculate_length(code_size + String.to_integer(n) * extended_length(subsequent))
  end
  defp calculate_length([], code_size), do: code_size
  defp calculate_length([_ | rest], code_size), do: calculate_length(rest, code_size + 1)
end
