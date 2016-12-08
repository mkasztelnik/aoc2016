defmodule Aoc2016.Day4 do
  @doc ~S"""
  Finally, you come across an information kiosk with a list of rooms. Of course,
  the list is encrypted and full of decoy data, but the instructions to decode
  the list are barely hidden nearby. Better remove the decoy data first.

  Each room consists of an encrypted name (lowercase letters separated by
  dashes) followed by a dash, a sector ID, and a checksum in square brackets.

  A room is real (not a decoy) if the checksum is the five most common letters
  in the encrypted name, in order, with ties broken by alphabetization. For
  example:

    - aaaaa-bbb-z-y-x-123[abxyz] is a real room because the most common
      letters are a (5), b (3), and then a tie between x, y, and z, which
      are listed alphabetically.
    - a-b-c-d-e-f-g-h-987[abcde] is a real room because although the
      letters are all tied (1 of each), the first five are listed alphabetically.
    - not-a-real-room-404[oarel] is a real room.
    - totally-real-room-200[decoy] is not.

  Of the real rooms from the list above, the sum of their sector IDs is 1514.

  iex> Aoc2016.Day4.real_rooms_ids_sum("aaaaa-bbb-z-y-x-123[abxyz]\na-b-c-d-e-f-g-h-987[abcde]\nnot-a-real-room-404[oarel]\ntotally-real-room-200[decoy]")
  1514
  """
  def real_rooms_ids_sum(rooms_str) do
    valid_rooms(rooms_str)
    |> Enum.reduce(0, fn(x, acc) -> String.to_integer(x["id"]) + acc end)
  end

  defp valid_rooms(rooms_str) do
    rooms_str
    |> String.split("\n")
    |> Enum.map(fn(room_str) -> room_str |> String.strip |> parse end)
    |> Enum.filter(&valid?/1)
  end

  defp valid?(%{"name" => name, "hash" => hash}) do
    name
    |> String.replace("-", "")
    |> String.graphemes
    |> Enum.group_by(&Base.encode16/1)
    |> Dict.values
    |> Enum.sort(fn(e1, e2) -> List.first(e1) > List.first(e2) end)
    |> Enum.sort(fn(e1, e2) -> Enum.count(e1) > Enum.count(e2) end)
    |> Enum.take(5)
    |> Enum.map(&List.first(&1))
    |> Enum.join("") == hash
  end

  defp parse(room_str) do
    Regex.named_captures(
      ~r/(?<name>([a-zA-Z]+-)+)(?<id>\d{3})\[(?<hash>[a-zA-Z]{5})]/, room_str)
  end

  @doc ~S"""
  With all the decoy data out of the way, it's time to decrypt this list and get
  moving.

  The room names are encrypted by a state-of-the-art shift cipher, which is
  nearly unbreakable without the right software. However, the information kiosk
  designers at Easter Bunny HQ were not expecting to deal with a master
  cryptographer like yourself.

  To decrypt a room name, rotate each letter forward through the alphabet a
  number of times equal to the room's sector ID. A becomes B, B becomes C, Z
  becomes A, and so on. Dashes become spaces.

  For example, the real name for "qzmt-zixmtkozy-ivhz-343" is "very encrypted
  name".

  iex> Aoc2016.Day4.decode("qzmt-zixmtkozy-ivhz-343[asdfg]")
  "very encrypted name"
  """
  def decode(room_str), do: room_str |> parse |> do_decode

  defp do_decode(%{"name" => name, "id" => id}) do
    nr = String.to_integer(id)
    name
    |> String.replace("-", " ")
    |> String.trim
    |> String.to_charlist
    |> Enum.map(&do_decode(&1, nr))
    |> to_string
  end
  defp do_decode(32, _), do: 32
  defp do_decode(ch, nr), do: rem(ch - 97 + nr, 26) + 97


  def find_room_sector_id(rooms_str) do
    rooms_str
    |> valid_rooms
    |> Enum.find(fn(x) ->
        Regex.match?(~r/.*north.*/, do_decode(x))
    end)
    |> id
  end

  defp id(nil), do: :error
  defp id(%{"id" => id}), do: String.to_integer(id)
end
