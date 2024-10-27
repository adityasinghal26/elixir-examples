defmodule IslandsEngine.IslandSet do
  alias IslandsEngine.{Island, IslandSet, Coordinate}

  # Define five islands of different shapes
  defstruct atoll: :none, dot: :none, l_shape: :none, s_shape: :none, square: :none

  # default to empty map
  # Initialize the island set with the keys
  def start_link() do
    Agent.start_link(fn -> initialized_set() end)
  end


  defp initialized_set() do
    Enum.reduce(keys(), %IslandSet{}, fn(key, set) ->
      {:ok, island} = Island.start_link
      Map.put(set, key, island)
      # passing the same map for next iteration (figuratively speaking)
      # creating a new map with updated value every time
    end )
  end

  # Get the island from the island set to update and capture its original coordinates
  # Replace the coordinates in the island with the new coordinates
  # Set the old coordinates without an island
  # Set the new coordinates with the island
  def set_island_coordinates(island_set, island_key, new_coordinates) do
    island = Agent.get(island_set, fn state -> Map.get(state, island_key) end)
    original_coordinates = Agent.get(island, fn state -> state end)

    Island.replace_coordinates(island, new_coordinates)
    Coordinate.set_all_in_island(original_coordinates, :none)
    Coordinate.set_all_in_island(new_coordinates, island_key)
  end

  # Check if the island is forested
  def forested?(island_set, :none) do
    false
  end

  def forested?(island_set, island_key) do
    island_set
    |> Agent.get(fn state -> Map.get(state, island_key) end)
    |> Island.forested?
  end

  # Since Maps.keys will return a list of atoms, along with :__struct__ atom
  # we need to filter out the :__struct__ atom
  defp keys() do
    %IslandSet{}
    |> Map.from_struct
    |> Map.keys
  end

  # Stringify the island set
  def to_string(island_set) do
    "%{" <> string_body(island_set) <> "}"
  end

  # Iterate over the island set and fetch the island for each key
  defp string_body(island_set) do
    Enum.reduce(keys(), "", fn key, acc ->
      island = Agent.get(island_set, &(Map.fetch!(&1, key)))
      # fetch! will raise an error if the key is not found
      # &(Map.fetch!(&1, key)) defines an anonymous function that takes one argument (a map)
      acc <> "#{key} => " <> Island.to_string(island) <> "\n"
    end )
  end

end
