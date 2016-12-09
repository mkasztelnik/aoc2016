defmodule Aoc2016.Day5 do
  @doc ~S"""
  You are faced with a security door designed by Easter Bunny engineers that
  seem to have acquired most of their security knowledge by watching hacking
  movies.

  The eight-character password for the door is generated one character at a time
  by finding the MD5 hash of some Door ID (your puzzle input) and an increasing
  integer index (starting with 0).

  A hash indicates the next character in the password if its hexadecimal
  representation starts with five zeroes. If it does, the sixth character in the
  hash is the next character of the password.

  For example, if the Door ID is abc:

    - The first index which produces a hash that starts with five zeroes is
      3231929, which we find by hashing abc3231929; the sixth character of
      the hash, and thus the first character of the password, is 1.

    - 5017308 produces the next interesting hash, which starts with 000008f82...,
      so the second character of the password is 8.

    - The third time a hash starts with five zeroes is for abc5278568,
      discovering the character f.

  In this example, after continuing this search a total of eight times, the
  password is 18f47a30.

  #iex> Aoc2016.Day5.password("abc")
  "18f47a30"
  """
  def password(input) do
    gen_pass(input, 0, "", 8)
  end

  def gen_pass(_, _, pass, 0), do: pass
  def gen_pass(input, nr, pass , count) do
    {rest, nr} = gen_next_pass_char(input, nr)
    gen_pass(input, nr + 1, pass <> String.first(rest), count - 1)
  end

  defp gen_next_pass_char(input, nr) do
    gen_next_pass_char(md5(input <> to_string(nr)), input, nr)
  end
  defp gen_next_pass_char("00000" <> rest, _, nr), do: {rest, nr}
  defp gen_next_pass_char(_, input, nr), do: gen_next_pass_char(input, nr + 1)

  defp md5(str), do: Base.encode16(:erlang.md5(str), case: :lower)

  @doc ~S"""
  As the door slides open, you are presented with a second door that uses a
  slightly more inspired security mechanism. Clearly unimpressed by the last
  version (in what movie is the password decrypted in order?!), the Easter Bunny
  engineers have worked out a better solution.

  Instead of simply filling in the password from left to right, the hash now
  also indicates the position within the password to fill. You still look for
  hashes that begin with five zeroes; however, now, the sixth character
  represents the position (0-7), and the seventh character is the character to
  put in that position.

  A hash result of 000001f means that f is the second character in the password.
  Use only the first result for each position, and ignore invalid positions.

  For example, if the Door ID is abc:

    - The first interesting hash is from abc3231929, which produces 0000015...;
      so, 5 goes in position 1: _5______.

    - In the previous method, 5017308 produced an interesting hash; however,
      it is ignored, because it specifies an invalid position (8).

    - The second interesting hash is at index 5357525, which produces 000004e...;
      so, e goes in position 4: _5__e___.

  You almost choke on your popcorn as the final character falls into place,
  producing the password 05ace8e3.

  # iex> Aoc2016.Day5.password2("abc")
  # "05ace8e3"
  """
  def password2(input) do
    pass = {nil, nil, nil, nil, nil, nil, nil, nil}
    gen_pass2(input, 0, pass)
    |> Tuple.to_list
    |> Enum.join("")
  end

  defp gen_pass2(input, nr, pass) do
    case valid?(pass) do
      true -> pass
      _ ->
          {ch, next_nr} = gen_next_pass_char(input, nr + 1)
          gen_pass2(input, next_nr, pass, ch)
    end
  end
  defp gen_pass2(input, nr, pass, hash_rest) do
    case String.first(hash_rest) |> Integer.parse do
      {8, _}  -> gen_pass2(input, nr + 1, pass)
      {9, _}  -> gen_pass2(input, nr + 1, pass)
      {x, _} -> gen_pass2(input, nr + 1, update_pass(pass, x, String.at(hash_rest, 1)))
      :error  -> gen_pass2(input, nr + 1, pass)
    end
  end

  defp update_pass(pass, possition, ch) do
    case elem(pass, possition) do
      nil -> pass |> Tuple.delete_at(possition) |> Tuple.insert_at(possition, ch)
      _ -> pass
    end
  end

  defp valid?(pass) do
    pass
    |> Tuple.to_list
    |> Enum.find_index(fn(x) -> x == nil end) == nil
  end
end
