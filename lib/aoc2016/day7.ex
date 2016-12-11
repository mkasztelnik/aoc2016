defmodule Aoc2016.Day7 do
  @doc ~S"""
  While snooping around the local network of EBHQ, you compile a list of IP
  addresses (they're IPv7, of course; IPv6 is much too limited). You'd like to
  figure out which IPs support TLS (transport-layer snooping).

  An IP supports TLS if it has an Autonomous Bridge Bypass Annotation, or ABBA.
  An ABBA is any four-character sequence which consists of a pair of two
  different characters followed by the reverse of that pair, such as xyyx or
  abba. However, the IP also must not have an ABBA within any hypernet
  sequences, which are contained by square brackets.

  For example:

    - abba[mnop]qrst supports TLS (abba outside square brackets).

    - abcd[bddb]xyyx does not support TLS (bddb is within square brackets, even
      though xyyx is outside square brackets).

    - aaaa[qwer]tyui does not support TLS (aaaa is invalid; the interior characters
      must be different).

    - ioxxoj[asdfgh]zxcvbn supports TLS (oxxo is outside square brackets, even
      though it's within a larger string).

  iex> Aoc2016.Day7.supports_tls?("abba[mnop]qrst")
  true

  iex> Aoc2016.Day7.supports_tls?("abcd[bddb]xyyx")
  false

  iex> Aoc2016.Day7.supports_tls?("aaaa[qwer]tyui")
  false

  iex> Aoc2016.Day7.supports_tls?("ioxxoj[asdfgh]zxcvbn")
  true
  """
  def supports_tls?(address) do
    no_abba_in_square?(address) && abba_in_other_place?(address)
  end

  defp no_abba_in_square?(address) do
    abba = Regex.scan(~r/\[\w+\]/, address)
           |> Enum.flat_map(&(&1))
           |> Enum.map(&String.slice(&1, 1..-2))
           |> Enum.find(&abba?/1)
    abba == nil
  end

  defp abba_in_other_place?(address) do
    abba = address
           |> String.split(~r/\[\w+\]/)
           |> Enum.find(&abba?/1)
    abba != nil
  end

  defp abba?(str) when is_bitstring(str), do: str |> String.graphemes |> abba?
  defp abba?([a | [a | [a | [a | rest]]]]), do: abba?([a | [a | rest]])
  defp abba?([a | [b | [b | [a | _]]]]), do: true
  defp abba?([_ | rest]), do: abba?(rest)
  defp abba?([]), do: false
