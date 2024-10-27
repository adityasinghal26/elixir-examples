defmodule IslandsEngine.Board do
  alias IslandsEngine.Coordinate

  # Empty map is the default state
  # Initialize the board with the keys
  def start_link() do
    Agent.start_link(fn -> initialized_board() end)
  end


  # Generate the new keys in the Board state
  @letters ~W(a b c d e f g h i j)
  @numbers [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  defp keys() do
    for letter <- @letters, number <- @numbers do
      # Convert the letter and number to an atom
      String.to_atom("#{letter}#{number}")
    end
  end

  defp initialized_board() do
    # Iterate over the keys,
    # Create the coordinates with the start_link function,
    # Initialize the board by putting the coordinates in the map
    Enum.reduce(keys(), %{}, fn(key, board) ->
      {:ok, coord} = Coordinate.start_link
      Map.put_new(board, key, coord) # creating the new map for next iteration
    end )
  end

  # Get the named coordinate from the board
  def get_coordinate(board, key) when is_atom key do
    Agent.get(board, fn board -> board[key] end)
  end

  # Get the coordinate from the board
  # and guess the coordinate
  def guess_coordinate(board, key) do
    get_coordinate(board, key)
    |> Coordinate.guess
  end

  # Get the coordinate and check if it is a hit
  def coordinate_hit(board, key) do
    get_coordinate(board, key)
    |> Coordinate.hit?
  end

  # Set the coordinate in the island
  def set_coordinate_in_island(board, key, island) do
    get_coordinate(board, key)
    |> Coordinate.set_in_island(island)
  end

  # Check which island the coordinate is in
  def coordinate_island(board, key) do
    get_coordinate(board, key)
    |> Coordinate.island
  end

  # Stringify the board
  def to_string(board) do
    "%{" <> string_body(board) <> "}"
  end

  # Iterate over the board and fetch the coordinate for each key
  defp string_body(board) do
    Enum.reduce(keys(), "", fn key, acc ->
      coord = get_coordinate(board, key)
      acc <> "#{key} => #{Coordinate.to_string(coord)}, \n"
    end )
  end

end
