defmodule ValidatorTest do
  @moduledoc """
  Validator Unit test.
  """
  use ExUnit.Case
  alias Thirteen.Validator
  alias Deck.Card

  setup_all do
    cards_on_table = [
      Card.new({"AA", 51}),
      Card.new({"AC", 38}),
      Card.new({"AD", 25})
    ]

    {:ok, cards_on_table: cards_on_table}
  end

  describe "Validator Module" do
    test "Return true when card thrown is available and is of the same face as of the first card on table",
         state do
      cards_on_table = state[:cards_on_table]

      cards_with_player = [
        Card.new({"AH", 12}),
        Card.new({"KH", 11}),
        Card.new({"KA", 50})
      ]

      card = Card.new({"KA", 50})
      assert true == card |> Validator.valid_throw?(cards_with_player, cards_on_table)
    end

    test "Return true when card thrown is available and is not of the same face as of the first card on table as player doesn't have the face",
         state do
      cards_on_table = state[:cards_on_table]

      cards_with_player = [
        Card.new({"AH", 12}),
        Card.new({"KH", 11})
      ]

      card = Card.new({"AH", 12})
      assert true == card |> Validator.valid_throw?(cards_with_player, cards_on_table)
    end

    test "Return error when card thrown is not available with player", state do
      cards_on_table = state[:cards_on_table]

      cards_with_player = [
        Card.new({"AH", 12}),
        Card.new({"KH", 11})
      ]

      card = Card.new({"KA", 50})

      assert {:error, :CARD_NOT_AVAILABLE} ==
               card |> Validator.valid_throw?(cards_with_player, cards_on_table)
    end

    test "Return error when card thrown is available and is not of the same face as of the first card on table but player has the face",
         state do
      cards_on_table = state[:cards_on_table]

      cards_with_player = [
        Card.new({"KH", 11}),
        Card.new({"KA", 50})
      ]

      card = Card.new({"KH", 11})

      assert {:error, :BETTER_CARD_AVAILABLE} ==
               card |> Validator.valid_throw?(cards_with_player, cards_on_table)
    end
  end
end
