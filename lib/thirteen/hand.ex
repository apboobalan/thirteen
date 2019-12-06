defmodule Thirteen.Hand do
  @moduledoc """
  Hand Struct.
  """
  @derive Jason.Encoder
  defstruct cards: nil, expected_bet: 0, actual_bet: 0, points: 0

  @doc """
  New Hand.
  """
  def new(), do: %__MODULE__{}

  @doc """
  Cards setter.
  """
  def set_cards(hand, cards), do: hand |> Map.put(:cards, cards)

  @doc """
  Cards getter.
  """
  def get_cards(hand), do: hand |> Map.get(:cards)

  @doc """
  Expected bet setter.
  """
  def set_expected_bet(hand, bet), do: hand |> Map.put(:expected_bet, bet)

  @doc """
  Expected bet getter.
  """
  def get_expected_bet(hand), do: hand |> Map.get(:expected_bet)

  @doc """
  Actual bet setter.
  """
  def set_actual_bet(hand, bet), do: hand |> Map.put(:actual_bet, bet)

  @doc """
  Actual bet getter.
  """
  def get_actual_bet(hand), do: hand |> Map.get(:actual_bet)

  @doc """
  Points setter.
  """
  def set_points(hand, points), do: hand |> Map.put(:points, points)

  @doc """
  Points getter.
  """
  def get_points(hand), do: hand |> Map.get(:points)

  @doc """
  Reset Expected Bet.
  """
  def reset_expected_bet(hand), do: hand |> set_expected_bet(0)

  @doc """
  Reset Actual Bet.
  """
  def reset_actual_bet(hand), do: hand |> set_actual_bet(0)

  @doc """
  Update points based on expected bet placed and actual bet won.
  """
  def update_points(hand) do
    updated_points = (hand |> get_points) + (hand |> points_this_round)
    hand |> set_points(updated_points)
  end

  defp points_this_round(hand),
    do: points_this_round(hand |> get_expected_bet, hand |> get_actual_bet)

  defp points_this_round(expected, actual) when actual >= expected,
    do: actual - expected + expected * 10

  defp points_this_round(expected, _actual), do: -(expected * 10)

  @doc """
  Actual bet incrementor.
  """
  def increment_actual_bet_by_one(hand) do
    actual_bet = hand |> get_actual_bet
    hand |> set_actual_bet(actual_bet + 1)
  end
end
