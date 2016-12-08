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

  #iex> Aoc2016.Day5.password("abc", 8)
  "18f47a30"
  """
  def password(input, count) do
    gen_pass(input, 0, "", count)
  end

  def gen_pass(_, _, pass, 0), do: pass
  def gen_pass(input, nr, pass , count) do
    {ch, nr} = gen_next_pass_char(input, nr)
    gen_pass(input, nr + 1, pass <> ch, count - 1)
  end

  defp gen_next_pass_char(input, nr) do
    gen_next_pass_char(md5(input <> to_string(nr)), input, nr)
  end
  defp gen_next_pass_char("00000" <> rest, _, nr), do: {String.first(rest), nr}
  defp gen_next_pass_char(_, input, nr), do: gen_next_pass_char(input, nr + 1)

  defp md5(str), do: Base.encode16(:erlang.md5(str), case: :lower)
end
