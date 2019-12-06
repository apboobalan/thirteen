defmodule Thirteen.Thirteen do
  alias Thirteen.{Game, Hand, Next}

  @moduledoc """
  Core gameplay.
  """

  @doc """
  Initialize Game.
  """
  def new(name), do: Game.new(name) |> Game.start_joining()

  @doc """
  Initialize Game for test with deterministic(ordered) cards.
  """
  def new_test_game(name), do: Game.new_test_game(name) |> Game.start_joining()

  @doc """
  Join Players.
  """
  def join(game, name), do: game |> Game.join(name)

  @doc """
  Starts Game.
  """
  def start(game), do: game |> Game.start() |> Game.serve()

  @doc """
  Place Bet on how many cards we can win in this round.
  """
  def bet(game, bet) when is_integer(bet) do
    game |> Game.add_expected_bet(bet) |> Game.reduce_remaining_bets() |> Next.throw_card_or_bet()
  end

  @doc """
  Throw Card on table.
  """
  def throw(game, card) do
    game
    |> Game.add_card_to_table(card)
    |> Next.collect_or_throw_card()
  end

  @doc """
  Winner is choosen and all cards are collected by him
  """
  def collect(game) do
    winner_card = game.on_table |> Game.pick_winner_card()
    winner = game.in_hands |> Game.pick_winner(winner_card)
    winner_hand = game.in_hands |> Game.get(winner)

    game
    |> Game.set_in_hands(
      game.in_hands
      |> Game.update_hand_in_hands(winner, winner_hand |> Hand.increment_actual_bet_by_one())
    )
    |> Game.discard_cards()
    |> Game.fix_next_round_player(winner)
    |> Game.clear_table()
    |> Game.reduce_remaining_cards()
    |> Next.throw_or_serve_or_show_result()
  end

  def show_result(game) do
    game |> Game.change_state(:finished)
  end
end
