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
    inside_square_parts(address) |> Enum.find(&abba?/1) == nil
  end

  defp inside_square_parts(address) do
    Regex.scan(~r/\[\w+\]/, address)
    |> Enum.flat_map(&(&1))
    |> Enum.map(&String.slice(&1, 1..-2))
  end

  defp abba_in_other_place?(address) do
    outside_square_parts(address) |> Enum.find(&abba?/1) != nil
  end

  defp outside_square_parts(address) do
    String.split(address, ~r/\[\w+\]/)
  end

  defp abba?(str) when is_bitstring(str), do: str |> String.graphemes |> abba?
  defp abba?([a | [a | [a | [a | rest]]]]), do: abba?([a | [a | rest]])
  defp abba?([a | [b | [b | [a | _]]]]), do: true
  defp abba?([_ | rest]), do: abba?(rest)
  defp abba?([]), do: false

  @doc ~S"""
  You would also like to know which IPs support SSL (super-secret listening).

  An IP supports SSL if it has an Area-Broadcast Accessor, or ABA, anywhere in
  the supernet sequences (outside any square bracketed sections), and a
  corresponding Byte Allocation Block, or BAB, anywhere in the hypernet
  sequences. An ABA is any three-character sequence which consists of the same
  character twice with a different character between them, such as xyx or aba. A
  corresponding BAB is the same characters but in reversed positions: yxy and
  bab, respectively.

  For example:

    - aba[bab]xyz supports SSL (aba outside square brackets with corresponding bab
      within square brackets).

    - xyx[xyx]xyx does not support SSL (xyx, but no corresponding yxy).

    - aaa[kek]eke supports SSL (eke in supernet with corresponding kek in hypernet;
      the aaa sequence is not related, because the interior character must be
      different).

    - zazbz[bzb]cdb supports SSL (zaz has no corresponding aza, but zbz has a
      corresponding bzb, even though zaz and zbz overlap).

  iex> Aoc2016.Day7.supports_ssl?("aba[bab]xyz")
  true

  iex> Aoc2016.Day7.supports_ssl?("xyx[xyx]xyx")
  false

  iex> Aoc2016.Day7.supports_ssl?("aaa[kek]eke")
  true

  iex> Aoc2016.Day7.supports_ssl?("zazbz[bzb]cdb")
  true
  """
  def supports_ssl?(address) do
    MapSet.intersection(MapSet.new(abas(address)), MapSet.new(babs(address)))
    |> MapSet.size > 0
  end

  defp abas(address) do
    address |> outside_square_parts() |> to_abas()
  end

  defp inside_square_abas(address) do
    address |> inside_square_parts() |> to_abas()
  end

  defp to_abas(parts) do
    parts
    |> Enum.map(&to_aba/1)
    |> Enum.flat_map(&(&1))
  end

  defp babs(address) do
    address |> inside_square_abas |> to_babs
  end

  defp to_aba(str), do: to_aba([], String.graphemes(str))
  defp to_aba(abas, [a | [b | [a | rest]]]) when a != b do
    to_aba([a <> b <> a | abas], [b | [a | rest]])
  end
  defp to_aba(abas, [_ | rest]), do: to_aba(abas, rest)
  defp to_aba(abas, []), do: abas


  defp to_babs(abas) do
    Enum.map(abas, &to_bab/1)
  end

  defp to_bab(<<a :: utf8, b :: utf8, a ::utf8>>), do: <<b, a, b>>
  defp to_bab(_), do: :error
end
