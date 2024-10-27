defmodule IslandsEngine.Game do
  use GenServer

  alias IslandsEngine.{Game, Player}

  defstruct player1: :none, player2: :none

  ## ---- Client functions ---- ##
  # start_link/3 to spawn the new process
  # triggers the init/1 callback function
  def start_link(name) when is_binary(name) and byte_size(name) > 0 do
    GenServer.start_link(__MODULE__, name, name: {:global, "game:#{name}"})
  end

  def call_demo(game) do
    GenServer.call(game, :demo)
  end

  # Not needed for this exercise
  # Cast /2 is used to not send any reply state to the caller
  # def cast_demo(pid) do
  #   GenServer.cast(pid, :demo)
  # end

  def add_player(game, name) when name != nil do
    GenServer.call(game, {:add_player, name})
  end

  def set_island_coordinates(game, player, island, cooordinates)
    when is_atom(player) and is_atom(island) do
      GenServer.call(game, {:set_island_coordinates, player, island, cooordinates})
  end

  def guess_coordinate(game, player, coordinate)
    when is_atom(player) and is_atom(coordinate) do
      GenServer.call(game, {:guess, player, coordinate})
  end

  def stop(game) do
    GenServer.cast(game, :stop)
  end

  ## ---- GenServer functions ---- ##
  # init/1 to initialize the process
  def init(name) do
    {:ok, player1} = Player.start_link(name)
    {:ok, player2} = Player.start_link()
    {:ok, %Game{player1: player1, player2: player2}}
  end

  # Not needed for this exercise
  # def handle_info(:first, state) do
  #   IO.puts "This message has been handled by handle_info/2, matching on :first."
  #   {:noreply, state}
  # end

  # Not needed for this exercise
  # def handle_cast(:demo, state) do
  #   {:noreply, %{state | test: "new value"}}
  # end

  def handle_call(:demo, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:add_player, name}, _from, state) do
    Player.set_name(state.player2, name)
    {:reply, :ok, state}
  end

  def handle_call({:set_island_coordinates, player, island, coordinates}, _from, state) do
    state
    |> Map.get(player)
    |> Player.set_island_coordinates(island, coordinates)
    {:reply, :ok, state}
  end

  def handle_call({:guess, player, coordinate}, _from, state) do
    opponent = opponent(state, player)
    opponent_board = Player.get_board(opponent)
    Player.guess_coordinate(opponent_board, coordinate)
    |> forest_check(opponent, coordinate)
    |> win_check(opponent, state)
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  ## ---- Private functions ---- ##
  # Get the opponent player
  defp opponent(state, :player1) do
    state.player2
  end

  defp opponent(state, :player2) do
    state.player1
  end

  defp forest_check(:miss, _opponent, _coordinate) do
    {:miss, :none}
  end

  defp forest_check(:hit, opponent, coordinate) do
    island_key = Player.forested_island(opponent, coordinate)
    {:hit, island_key}
    # return island_key if it's forested
    # else, it returns :none
  end

  # If the guess is hit or miss, but the island is not forested
  # it will return :no_win
  defp win_check({hit_or_miss, :none}, _opponent, state) do
    {:reply, {hit_or_miss, :none, :no_win}, state}
  end

  # If the guess is hit and forests the island_key
  # Check if the player has won
  defp win_check({:hit, island_key}, opponent, state) do
    win_status =
    case Player.win?(opponent) do
      true -> :win
      false -> :no_win
    end
    {:reply, {:hit, island_key, win_status}, state}
  end

end
