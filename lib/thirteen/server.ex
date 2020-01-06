defmodule Thirteen.Server do
  @moduledoc """
  Game server.
  """
  alias Thirteen.Play

  @game_timeout 3_000_000
  use GenServer
  def start_link(name), do: GenServer.start_link(__MODULE__, name, name: name |> via_tuple)
  def init(name) do
    self() |> Process.send_after({:terminate_game}, @game_timeout)
    Play.new(name)
  end
  def alive?(game), do: game |> pid |> alive
  def alive(:undefined), do: false
  def alive(_), do: true
  def join(game, name), do: game |> via_tuple |> GenServer.call({:join, name})
  def start(game), do: game |> via_tuple |> GenServer.call({:start})
  def play(game, player, input), do: game |> via_tuple |> GenServer.call({:play, player, input})
  def cards(game, player), do: game |> via_tuple |> GenServer.call({:cards, player})
  def game_state(game), do: game |> via_tuple |> GenServer.call({:game_state})

  def pid(game), do: {:game_registry, game} |> Registry.whereis_name()

  def handle_call({:start}, _from, state) do
    state |> Play.start() |> generate_reply(state)
  end

  def handle_call({:join, name}, _from, state) do
    state |> Play.join(name) |> generate_reply(state)
  end

  def handle_call({:play, player, input}, _from, state) do
    state |> Play.play(player, input) |> generate_reply(state)
  end

  def handle_call({:cards, player}, _from, state) do
    {:reply, state |> Play.cards(player), state}
  end

  def handle_call({:game_state}, _from, state) do
    {:reply, state |> Play.game_state(), state}
  end
  #TODO do we need to add brackets around the atoms.
  def handle_info({:terminate_game}, state) do
    Thirteen.GameSupervisor.stop_child(state.name)
    {:noreply, state}
  end

  def terminate(reason, _state), do: reason

  defp generate_reply({:ok, new_state}, _state), do: {:reply, {:ok, new_state}, new_state}
  defp generate_reply({:error, error}, state), do: {:reply, {:error, error}, state}

  def via_tuple(name), do: {:via, Registry, {:game_registry, name}}
end
