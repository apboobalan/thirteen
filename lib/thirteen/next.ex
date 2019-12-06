defmodule Thirteen.Next do
  @moduledoc """
  Find Next State of the Game.
  """
  alias Thirteen.{Thirteen, Game, Hand}

  def throw_card_or_bet(%Game{remaining_bets: 0} = game),
    do: game |> Game.change_state(:throw_card) |> Game.change_start_hand()

  def throw_card_or_bet(game), do: game |> Game.change_state(:bet) |> Game.next_play_hand()

  def collect_or_throw_card(game = %Game{on_table: on_table, hands: hands})
      when on_table |> length == hands,
      do: game |> Thirteen.collect()

  def collect_or_throw_card(game), do: game |> Game.next_play_hand()

  def next_round(game),
    do:
      game
      |> Game.increase_cards()
      |> Game.set_remaining_cards_to_cards()
      |> Game.set_remaining_bets_to_hands()

  @rounds 13
  def throw_or_serve_or_show_result(%Game{remaining_cards: 0, cards: @rounds} = game),
    do: game |> update_bets_and_points |> Thirteen.show_result()

  def throw_or_serve_or_show_result(%Game{remaining_cards: 0} = game),
    do:
      game
      |> update_bets_and_points
      |> next_round
      |> Game.serve()

  def throw_or_serve_or_show_result(game), do: game |> Game.change_state(:throw_card)

  def update_bets_and_points(game) do
    update_points_function = fn {key, hand} ->
      {key, hand |> Hand.update_points() |> Hand.reset_expected_bet() |> Hand.reset_actual_bet()}
    end

    game |> Game.update_hands_using(update_points_function)
  end
end
