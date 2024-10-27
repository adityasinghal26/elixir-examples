defmodule IslandsEngine.IslandSet do
  alias IslandsEngine.{Island, IslandSet}

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
