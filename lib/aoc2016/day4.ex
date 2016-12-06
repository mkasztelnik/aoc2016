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
    rooms_str
    |> String.split("\n")
    |> Enum.map(fn(room_str) -> String.strip(room_str) |> id end)
    |> Enum.reduce(0, fn(x, acc) -> x + acc end)
  end

  defp id(%{"name" => name, "hash" => hash, "id" => id}) do
    id(valid?(name, hash), id)
  end
  defp id(room_str), do: room_str |> parse |> id
  defp id(true, id) do
    {i, _ } = Integer.parse(id)
    i
  end
  defp id(_, _), do: 0

  defp valid?(name, hash) do
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

  defp parse(room) do
    Regex.named_captures(
      ~r/(?<name>([a-zA-Z]+-)+)(?<id>\d{3})\[(?<hash>[a-zA-Z]{5})]/, room)
  end
end
