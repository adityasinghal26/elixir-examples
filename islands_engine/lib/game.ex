defmodule IslandsEngine.Game do
  use GenServer

  alias IslandsEngine.{Game, Player}

  defstruct player1: :none, player2: :none

  # init/1 to initialize the process
  def init(init_arg) do
    {:ok, init_arg}
  end


  ## ---- Client functions ---- ##
  def call_demo(game) do
    GenServer.call(game, :demo)
  end

  def cast_demo(pid) do
    GenServer.cast(pid, :demo)
  end

  ## ---- Callback functions ---- ##
  def handle_info(:first, state) do
    IO.puts "This message has been handled by handle_info/2, matching on :first."
    {:noreply, state}
  end

  def handle_call(:demo, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:demo, state) do
    {:noreply, %{state | test: "new value"}}
  end

end
