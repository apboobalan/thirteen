defmodule HandTest do
  @moduledoc """
  Hands Unit test.
  """
  use ExUnit.Case
  alias Thirteen.Hand
  doctest Thirteen

  describe "Hand Module" do
    test "Generate a new Hand" do
      hand = Hand.new()
      assert hand.cards == nil
      assert hand.expected_bet == 0
      assert hand.actual_bet == 0
      assert hand.points == 0
    end

    test "Reset only expected bet" do
      hand = Hand.new |> Hand.set_expected_bet(5)
      new_hand = hand |> Hand.reset_expected_bet()
      assert new_hand.expected_bet == 0
      assert new_hand.actual_bet == hand.actual_bet
      assert new_hand.points == hand.points
      assert new_hand.cards == hand.cards
    end

    test "Reset only actual bet" do
      hand = Hand.new |> Hand.set_actual_bet(5)
      new_hand = hand |> Hand.reset_actual_bet()
      assert new_hand.actual_bet == 0
      assert new_hand.expected_bet == hand.expected_bet
      assert new_hand.points == hand.points
      assert new_hand.cards == hand.cards
    end

    test "Increase actual bet value by one" do
      hand = Hand.new |> Hand.set_actual_bet(5)
      new_hand = hand |> Hand.increment_actual_bet_by_one()
      assert new_hand.actual_bet == hand.actual_bet + 1
    end
  end

  describe "Update Points for the current round" do
    test "When actual bet is equal to expected bet" do
      hand = Hand.new |> Hand.set_actual_bet(5) |> Hand.set_expected_bet(5) |> Hand.set_points(5) |> Hand.update_points()
      assert hand.points == 55
    end

    test "when actual bet is less than expected bet" do
      hand = Hand.new |> Hand.set_actual_bet(5) |> Hand.set_expected_bet(7) |> Hand.set_points(5) |> Hand.update_points()
      assert hand.points == -65
    end

    test "when actual bet is greater than expected bet" do
      hand = Hand.new |> Hand.set_actual_bet(7) |> Hand.set_expected_bet(5) |> Hand.set_points(5) |> Hand.update_points()
      assert hand.points == 57
    end
  end
  describe "Test setters and getters for coverage" do
    hand = Hand.new
    cards = ["AA", "AH"]
    hand = hand |> Hand.set_cards(["AA", "AH"])
    assert hand |> Hand.get_cards() == cards
    expected_bet = 5
    hand = hand |> Hand.set_expected_bet(expected_bet)
    assert hand |> Hand.get_expected_bet() == expected_bet
    actual_bet = 7
    hand = hand |> Hand.set_actual_bet(actual_bet)
    assert hand |> Hand.get_actual_bet() == actual_bet
    points = 300
    hand = hand |> Hand.set_points(points)
    assert hand |> Hand.get_points() == points
  end
end
