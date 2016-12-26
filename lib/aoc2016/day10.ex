defmodule Aoc2016.Day10 do
  @doc ~S"""
  You come upon a factory in which many robots are zooming around handing small
  microchips to each other.

  Upon closer examination, you notice that each bot only proceeds when it has
  two microchips, and once it does, it gives each one to a different bot or puts
  it in a marked "output" bin. Sometimes, bots take microchips from "input"
  bins, too.

  Inspecting one of the microchips, it seems like they each contain a single
  number; the bots must use some logic to decide what to do with each chip. You
  access the local control computer and download the bots' instructions (your
  puzzle input).

  Some of the instructions specify that a specific-valued microchip should be
  given to a specific bot; the rest of the instructions indicate what a given
  bot should do with its lower-value or higher-value chip.

  For example, consider the following instructions:

    value 5 goes to bot 2
    bot 2 gives low to bot 1 and high to bot 0
    value 3 goes to bot 1
    bot 1 gives low to output 1 and high to bot 0
    bot 0 gives low to output 2 and high to output 0
    value 2 goes to bot 2

    - Initially, bot 1 starts with a value-3 chip, and bot 2 starts with a value-2
      chip and a value-5 chip.

     - Because bot 2 has two microchips, it gives its lower one (2) to bot 1 and
       its higher one (5) to bot 0.

    - Then, bot 1 has two microchips; it puts the value-2 chip in output 1 and
      gives the value-3 chip to bot 0.

    - Finally, bot 0 has two microchips; it puts the 3 in output 2 and the 5 in
      output 0.

  In the end, output bin 0 contains a value-5 microchip, output bin 1 contains a
  value-2 microchip, and output bin 2 contains a value-3 microchip. In this
  configuration, bot number 2 is responsible for comparing value-5 microchips
  with value-2 microchips.

  Based on your instructions, what is the number of the bot that is responsible
  for comparing value-61 microchips with value-17 microchips?

  What do you get if you multiply together the values of one chip in each of
  outputs 0, 1, and 2?
  """
  def run(instructions_str) do
    instructions = instructions_str
                  |> String.split("\n", trim: true)

    train(instructions)
    |> Aoc2016.Day10.Dispatcher.start_link()

    init_values(instructions)
    |> Enum.each(fn(%{nr:  nr, value: value}) ->
        Aoc2016.Day10.Dispatcher.dispatch({:robot, nr}, value)
      end)
  end

  defp train(instructions), do: train([], instructions)
  defp train(robots, []), do: robots
  defp train(robots, ["value" <> _ | rest]), do: train(robots, rest)
  defp train(robots, ["bot " <> instruction | rest]) do
    %{"b" => bot, "l" => low, "h" => high} =
      Regex.named_captures(
        ~r/(?<b>\d+) gives low to (?<l>(bot|output) \d+) and high to (?<h>(bot|output) \d+)/,
        instruction)

    train([%{nr: bot, low: parse(low), high: parse(high) } | robots], rest)
  end

  defp parse("bot " <> nr), do: {:robot, nr}
  defp parse("output " <> nr), do: {:output, nr}

  defp init_values(instructions), do: init_values([], instructions)
  defp init_values(values, []), do: Enum.reverse(values)
  defp init_values(values, ["bot" <> _ | rest]), do: init_values(values, rest)
  defp init_values(values, ["value" <> instruction | rest]) do
    %{"v" => v, "nr" => nr } = Regex.named_captures(~r/(?<v>\d+) goes to bot (?<nr>\d+)/, instruction)
    init_values([%{nr: nr, value: String.to_integer(v)} | values], rest)
  end
end

defmodule Aoc2016.Day10.Dispatcher do
  use GenServer

  def start_link(instructions) do
    GenServer.start_link(__MODULE__,
      %{outputs: %{}, robots: start_robots(instructions)},
      name: __MODULE__)
  end

  defp start_robots(instructions) do
    instructions
    |> Enum.map(fn(%{nr: nr} = specification) ->
        {:ok, pid} = Aoc2016.Day10.Robot.start_link(specification)
        {nr, pid}
      end)
    |> Enum.into(%{})
  end

  def dispatch(to, value) do
    GenServer.call(__MODULE__, {to, value})
  end

  def stop() do
    GenServer.call(__MODULE__, :stop)
    GenServer.stop(__MODULE__)
  end

  def outputs() do
    GenServer.call(__MODULE__, :outputs)
  end

  def handle_call({{:robot, nr}, value}, _from, state) do
    GenServer.cast(state.robots[nr], value)
    {:reply, :ok, state}
  end

  def handle_call({{:output, nr}, value}, _from, state) do
    IO.puts "state outputs #{inspect(state.outputs)}"
    {:reply, :ok, put_in(state, [:outputs, nr], value)}
  end

  def handle_call(:stop, _from, state) do
    state.robots
    |> Map.values
    |> Enum.each(&GenServer.stop(&1))

    {:reply, :ok, state}
  end

  def handle_call(:outputs, _from, state) do
    IO.puts "state outputs #{inspect(state.outputs)}"
    {:reply, state.outputs, state}
  end
end

defmodule Aoc2016.Day10.Robot do
  use GenServer

  def start_link(specification) do
    GenServer.start_link(__MODULE__, Map.put(specification, :value, nil))
  end

  def handle_cast(value, state) do
    case state.value do
      nil -> {:noreply, %{state | value: value}}
      _ ->
        check(state.value, value, state.nr)
        perform(state.value, value, state)
        {:noreply, state}
    end
  end

  defp perform(v1, v2, %{low: low_to, high: high_to}) do
    %{low: low, high: high} = lh(v1, v2)

    Aoc2016.Day10.Dispatcher.dispatch(low_to, low)
    Aoc2016.Day10.Dispatcher.dispatch(high_to, high)
  end

  defp check(61, 17, nr), do: IO.puts("Robot #{nr} is processing 61-17 !!!")
  defp check(17, 61, nr), do: IO.puts("Robot #{nr} is processing 61-17 !!!")
  defp check(_, _, _) do
  end

  defp lh(v1, v2) when v1 > v2, do: %{low: v2, high: v1}
  defp lh(v1, v2), do: %{low: v1, high: v2}
end
