# Description: This file contains the commands to run the application

# Recompile the ongoing IEX session
iex> recompile()

# Load the alias for the Coordinate module
iex> alias IslandsEngine.Coordinate

# Create a new coordinate
iex> %Coordinate{}
%IslandsEngine.Coordinate{in_island: :none, guessed?: false}

# Assign a coordinate
iex> coord = %Coordinate{}
%IslandsEngine.Coordinate{in_island: :none, guessed?: false}

# Get values of coord
iex> coord.in_island
:none

iex> coord.guessed?
false

# Assign a new value to coord
iex> coord = Map.put(coord, :guessed, true)
%IslandsEngine.Coordinate{in_island: :none, guessed?: true}

## ----------------- Working with Agents ----------------- ##
# Link Agent to a Coordinate state
iex> Agent.start_link(fn -> %Coordinate{} end)
{:ok, #PID<0.170.0>}

# Assign agent to a variable
iex> {:ok, coord} = Agent.start_link(fn -> %Coordinate{} end)
{:ok, #PID<0.172.0>}

# Run the custom start_link function
iex> {:ok, coordinate} = Coordinate.start_link
{:ok, #PID<0.130.0>}

# Get the state of the agent (without any transformation)
iex> coord = Agent.get(coordinate, fn state -> state end)
%IslandsEngine.Coordinate{in_island: :none, guessed?: false}

iex> coord = Agent.get(coordinate, fn state -> state.guessed? end)
iex> coord = Agent.get(coordinate, fn state -> state.in_island end)

# Create a new Agent with a new state
iex> {:ok, coordinate} = Agent.start_link(fn -> %Coordinate{guessed?: true, in_island: :my_island} end)
{:ok, #PID<0.131.0>}

# Transform the state of the agent
iex> Agent.update(coordinate, fn state -> Map.put(state, :guessed?, true) end)
:ok

# Get the state of the agent
iex> Coordinate.to_string coordinate
"(in_island: none, guessed: true)"

iex> IO.puts Coordinate.to_string coordinate
(in_island: none, guessed: true)
:ok

# Use of Maps.keys/1
iex> Map.keys(%{a: 1, b: 2})
[:a, :b]

# Use of Maps.from_struct/1
iex> Map.from_struct(%Coordinate{})
%{in_island: :none, guessed?: false}
iex> Map.keys(%Coordinate{})
[:__struct__, :in_island, :guessed?]