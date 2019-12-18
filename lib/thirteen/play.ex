defmodule Thirteen.Play do
  @moduledoc """
  API to play game.
  """

  alias Thirteen.{Game, Thirteen}
  def new(name), do: {:ok, Thirteen.new(name)}
  def new_test_game(name), do: {:ok, Thirteen.new_test_game(name)}

  def join(%Game{state: state} = game, name) when state != :join do
    case game |> Game.player_exists?(name) do
      true -> {:error, :PLAYER_NAME_ALREADY_EXISTS}
      false -> {:error, :GAME_IN_PROGRESS}
    end
  end

  def join(game, name) do
    game |> Game.player_exists?(name) |> join(game, name)
  end

  defp join(true, _game, _name), do: {:error, :PLAYER_NAME_ALREADY_EXISTS}
  defp join(false, game, name), do: game |> Thirteen.join(name) |> check_for_error_and_proceed

  def start(game), do: game |> Thirteen.start() |> check_for_error_and_proceed

  def play(game, player, input) do
    game |> Game.player_exists?(player) |> play_when_player_exists(game, player, input)
  end

  def play(%Game{state: :bet} = game, bet) when bet |> is_integer,
    do: game |> Thirteen.bet(bet)

  def play(%Game{state: :bet} = game, bet), do: play(game, bet |> String.to_integer())

  @card_names Deck.card_names()
  def play(%Game{state: :throw_card} = game, card_name) when card_name in @card_names do
    card = Deck.new() |> Cards.find_by_name(card_name)
    game |> Game.valid_throw?(card) |> throw_after_validation(game, card)
  end

  def play(%Game{state: :throw_card}, _card_name), do: {:error, :THROW_VALID_CARD}
  def play(%Game{state: :finished} = game, _input), do: game

  def game_state(%Game{state: :finished} = game), do: {:ok, game |> Game.get_game_result()}
  def game_state(game), do: {:ok, game |> Game.get_game_state()}

  defp play_when_player_exists(true, game, player, input),
    do: game |> Game.is_current_player(player) |> current_player_turn(game, input)

  defp play_when_player_exists(false, _game, _player, _input), do: {:error, :PLAYER_NOT_IN_GAME}

  defp current_player_turn(true, game, input),
    do: game |> play(input) |> check_for_error_and_proceed

  defp current_player_turn(false, _game, _input), do: {:error, :ANOTHER_PLAYER_TURN}

  defp throw_after_validation({:error, error}, _game, _card), do: {:error, error}
  defp throw_after_validation(true, game, card), do: game |> Thirteen.throw(card)

  defp check_for_error_and_proceed({:error, error}), do: {:error, error}
  defp check_for_error_and_proceed(new_game), do: {:ok, new_game}

  def player_name(game, player_index), do: game |> Game.player_name(player_index)
  def cards(game, player), do: game |> cards(game |> Game.player_exists?(player), player)
  defp cards(game, true, player), do: {:ok, game |> Game.cards(player)}
  defp cards(_game, false, _player), do: {:error, :PLAYER_NOT_IN_GAME}
end
