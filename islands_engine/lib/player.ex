defmodule IslandsEngine.Player do
  alias IslandsEngine.{Board, IslandSet, Player}

  # A player has a name, a board, and an island set
  defstruct name: :none, board: :none, island_set: :none

  def start_link(name \\ :none) do
    {:ok, board} = Board.start_link
    {:ok, island_set} = IslandSet.start_link
    Agent.start_link(fn -> %Player{board: board, island_set: island_set, name: name} end)
  end

  def set_name(player, name) do
    Agent.update(player, fn state -> Map.put(state, :name, name) end)
  end

  def get_board(player) do
    Agent.get(player, fn state -> state.board end)
  end

  def get_island_set(player) do
    Agent.get(player, fn state -> state.island_set end)
  end

  def set_island_coordinates(player, island, coordinates) do
    board = Player.get_board(player)
    island_set = Player.get_island_set(player)
    new_coordinates = convert_coordinates(board, coordinates)
    IslandSet.set_island_coordinates(island_set, island, new_coordinates)
  end

  # Convert the coordinate list to coordinate agents
  defp convert_coordinates(board, coordinates) do
    Enum.map(coordinates, fn coord -> convert_coordinate(board, coord) end)
  end

  # Get the coordinate agent for individual coordinate
  # If in case, the coordinate is already an agent (pid), return the agent
  defp convert_coordinate(board, coordinate) when is_atom coordinate do
    Board.get_coordinate(board, coordinate)
  end

  defp convert_coordinate(_board, coordinate) when is_pid coordinate do
    coordinate
  end

  # Guess the coordinate on the opponent board
  # If the coordinate is a hit, return :hit
  # If the coordinate is a miss, return :miss
  def guess_coordinate(opponent_board, coordinate) do
    Board.guess_coordinate(opponent_board, coordinate)
    case Board.coordinate_hit(opponent_board, coordinate) do
      true -> :hit
      false -> :miss
    end
  end

  def forested_island(opponent, coordinate) do
    board = Player.get_board(opponent)
    island_key = Board.coordinate_island(board, coordinate)
    island_set = Player.get_island_set(opponent)

    # if coordinate doesn't belong to any island, island_key will be :none
    case IslandSet.forested?(island_set, island_key) do
      true -> island_key
      false -> :none
    end
  end

  def win?(opponent) do
    opponent
    |> Player.get_island_set
    |> IslandSet.all_forested?
  end

  def to_string(player) do
    "%Player{" <> string_body(player) <> "}"
  end

  def string_body(player) do
    state = Agent.get(player, &(&1))
    ":name => " <> name_to_string(state.name) <> ",\n" <>
    ":island_set => " <> IslandSet.to_string(state.island_set) <> ",\n" <>
    ":board => " <> Board.to_string(state.board)
  end

  defp name_to_string(:none), do: ":none"
  defp name_to_string(name), do: ~s("#{name}")

end
