defmodule IslandsEngine.Island do
  alias IslandsEngine.Coordinate

  # Empty list is the default state
  def start_link() do
    Agent.start_link(fn -> [] end)
  end

  # Update the new coordinates in the Island state
  def replace_coordinates(island, new_coordinates) when is_list new_coordinates do
    Agent.update(island, fn _state -> new_coordinates end)
    # variable "state" is unused (if the variable is not meant to be used, prefix it with an underscore)
  end

  # Island is forested if all coordinates are hit
  def forested?(island) do
    island
    |> Agent.get(fn state -> state end)
    |> Enum.all?(fn coord -> Coordinate.hit?(coord) end)
  end

  # Stringify the island
  def to_string(island) do
    "[" <> coordinate_strings(island) <> "]"
  end

  # Iterate over the coordinates and convert them to strings
  defp coordinate_strings(island) do
    island
    |> Agent.get(fn state -> state end)
    |> Enum.map(fn coord -> Coordinate.to_string(coord) end)
    |> Enum.join(", ")
  end

end
