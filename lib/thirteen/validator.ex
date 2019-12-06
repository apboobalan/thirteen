defmodule Thirteen.Validator do
  @moduledoc """
  Validate Card Throw.
  """
  alias Deck.Card

  def valid_throw?(card, cards_with_player, cards_on_table) do

    with true <- available_card_thrown?(cards_with_player, cards_on_table, card),
         false <- better_card_available?(cards_with_player, cards_on_table, card) do
      true
    else
      {:error, error} -> {:error, error}
    end
  end

  defp available_card_thrown?(cards_with_player, _cards_on_table, card) do
    cards_with_player |> card_available?(card) |> card_available
  end

  defp card_available?(cards_with_player, card), do: cards_with_player |> Cards.present?(card)

  defp card_available(true), do: true
  defp card_available(false), do: {:error, :CARD_NOT_AVAILABLE}

  defp better_card_available?(_cards_with_player, _cards_on_table = [], _card), do: false

  defp better_card_available?(cards_with_player, [first_card_on_table | _], card) do
    card
    |> Card.same_face?(first_card_on_table)
    |> same_face_thrown(first_card_on_table, cards_with_player)
  end

  defp same_face_thrown(true, _first_card_on_table, _cards_with_player), do: false

  defp same_face_thrown(false, first_card_on_table, cards_with_player),
    do: first_card_on_table |> better_card_available?(cards_with_player)

  defp better_card_available?(first_card_on_table, cards_with_player) do
    cards_with_player
    |> Enum.any?(&Card.same_face?(first_card_on_table, &1))
    |> better_card_available
  end

  defp better_card_available(true), do: {:error, :BETTER_CARD_AVAILABLE}
  defp better_card_available(false), do: false
end
