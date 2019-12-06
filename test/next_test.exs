defmodule NextTest do
  @moduledoc """
  Next Moduel Unit test.
  """
  use ExUnit.Case
  import Mock
  alias Thirteen.{Game, Next, Thirteen}
  alias Deck.Card

  describe "Next Module Throw or Bet scenario" do
    test "Changes game to throwing hand state and changes the playing hand when the remaining bet is 0" do
      game =
        Game.new()
        |> Game.set_name("Rocket")
        |> Game.set_remaining_bets(0)
        |> Game.set_hands(3)
        |> Game.set_cards(4)
        |> Game.set_playing_hand(3)
        |> Next.throw_card_or_bet()

      assert game |> Game.get_state() == :throw_card
      assert game |> Game.get_playing_hand() == 2
    end

    test "Changes game to betting state and changes the start hand when the remaining bet is 0" do
      game =
        Game.new()
        |> Game.set_name("Rocket")
        |> Game.set_remaining_bets(1)
        |> Game.set_hands(3)
        |> Game.set_cards(4)
        |> Game.set_playing_hand(3)
        |> Next.throw_card_or_bet()

      assert game |> Game.get_state() == :bet
      assert game |> Game.get_playing_hand() == 1
    end
  end

  describe "Next Module Collect or Throw card scenario" do
    test "Changes playing hand when all the players havn't played cards yet" do
      game =
        Game.new()
        |> Game.set_name("Rocket")
        |> Game.set_hands(3)
        |> Game.set_playing_hand(3)
        |> Next.collect_or_throw_card()

      assert game |> Game.get_playing_hand() == 1
    end

    test "Call collect function when all players played their cards in the subround." do
      with_mock Thirteen, collect: fn _ -> "Mock Called" end do
        Game.new()
        |> Game.set_name("Rocket")
        |> Game.set_hands(3)
        |> Game.set_on_table([
          Card.new({"AA", 51}),
          Card.new({"AC", 38}),
          Card.new({"AD", 25})
        ])
        |> Next.collect_or_throw_card()

        assert called(Thirteen.collect(:_))
      end
    end
  end

  describe "Next Module Throw card or serve next round or show result" do
    test "Changes state to throw card when player has a remaining card" do
      game =
        Game.new()
        |> Game.set_name("Rocket")
        |> Game.set_remaining_cards(1)
        |> Next.throw_or_serve_or_show_result()

      assert game |> Game.get_state() == :throw_card
    end

    test "Call show result when we play last card of the last round" do
      with_mock Thirteen, show_result: fn _ -> "Mock Called" end do
        Game.new()
        |> Game.set_name("Rocket")
        |> Game.set_remaining_cards(0)
        |> Game.set_cards(13)
        |> Next.throw_or_serve_or_show_result()

        assert called(Thirteen.show_result(:_))
      end
    end

    test "Call serve when we play last card in the current round" do
      game =
        Game.new()
        |> Game.set_name("Rocket")
        |> Game.set_remaining_cards(0)
        |> Game.set_cards(4)

      with_mock Game,
        serve: fn _ -> "Mock Called" end,
        update_hands_using: fn _, _ -> "Mock Called" end,
        increase_cards: fn _ -> "Mock Called" end,
        set_remaining_cards_to_cards: fn _ -> "Mock Called" end,
        set_remaining_bets_to_hands: fn _ -> "Mock Called" end do
        game |> Next.throw_or_serve_or_show_result()
        assert called(Game.serve(:_))
      end
    end
  end
end
