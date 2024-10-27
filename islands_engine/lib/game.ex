defmodule IslandsEngine.Game do
  use GenServer

  alias IslandsEngine.{Game, Player}

  defstruct player1: :none, player2: :none

  # start_link/3 to spawn the new process
  # triggers the init/1 callback function
  def start_link(name) when not is_nil(name) do
    GenServer.start_link(__MODULE__, name)
  end

  # init/1 to initialize the process
  def init(name) do
    {:ok, player1} = Player.start_link(name)
    {:ok, player2} = Player.start_link()
    {:ok, %Game{player1: player1, player2: player2}}
  end

  ## ---- Client functions ---- ##
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

  ## ---- Callback functions ---- ##
  # Not needed for this exercise
  # def handle_info(:first, state) do
  #   IO.puts "This message has been handled by handle_info/2, matching on :first."
  #   {:noreply, state}
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
    response = Player.guess_coordinate(opponent_board, coordinate)
    {:reply, response, state}
  end

  # Not needed for this exercise
  # def handle_cast(:demo, state) do
  #   {:noreply, %{state | test: "new value"}}
  # end

  # Get the opponent player
  defp opponent(state, :player1) do
    state.player2
  end

  defp opponent(state, :player2) do
    state.player1
  end

end
