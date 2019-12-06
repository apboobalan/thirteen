defmodule Thirteen do
  @moduledoc """
  Api for Thirteen game.
  """
  def new(name), do: name |> Thirteen.GameSupervisor.start_child
  def join(game, name), do: game |> Thirteen.Server.join(name)
  def start(game), do: game |> Thirteen.Server.start
  def play(game, player, input), do: game |> Thirteen.Server.play(player, input)
  def alive?(game), do: game |> Thirteen.Server.alive?
  def stop(game), do: game |> Thirteen.GameSupervisor.stop_child
  def game_state(game), do: game |> Thirteen.Server.game_state
  def cards(game, player), do: game |> Thirteen.Server.cards(player)
end
