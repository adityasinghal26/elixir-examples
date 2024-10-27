defmodule IslandsEngine.Coordinate do
  defstruct in_island: :none, guessed?: false

  alias IslandsEngine.Coordinate

  def start_link() do
      Agent.start_link(fn -> %Coordinate{} end)
  end

  def island(coordinate) do
      Agent.get(coordinate, fn state -> state.in_island end)
  end

  def guessed?(coordinate) do
      Agent.get(coordinate, fn state -> state.guessed? end)
  end

  def in_island?(coordinate) do
      # If the coordinate has no island, return false
      case island(coordinate) do
          :none -> false
          _     -> true
      end
  end

  def hit?(coordinate) do
      in_island?(coordinate) && guessed?(coordinate)
  end

  # Guess can only happen once and this only false -> true is allowed
  def guess(coordinate) do
      Agent.update(coordinate, fn state -> Map.put(state, :guessed?, true) end)
  end

  # Show the entire state of the coordinate
  def to_string(coordinate) do
      # "#{inspect island(coordinate)}#{inspect guessed?(coordinate)}"
      "(in_island: #{island(coordinate)}, guessed: #{guessed?(coordinate)})"
  end
end
