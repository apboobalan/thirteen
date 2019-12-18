defmodule Thirteen.Game do
  @moduledoc """
  Game struct.
  """
  alias Thirteen.{Player, Hand, Validator}

  defstruct name: nil,
            players: [],
            in_hands: [],
            hands: 0,
            cards: 3,
            remaining_cards: 3,
            remaining_bets: 0,
            playing_hand: 1,
            on_table: [],
            state: :new,
            deck_module: Deck,
            result: nil

  @doc """
  New Game.
  """
  def new(name), do: new() |> set_name(name)

  def new, do: %__MODULE__{}
  def set_name(game, name), do: game |> Map.put(:name, name)
  def set_players(game, players), do: game |> Map.put(:players, players)
  def set_in_hands(game, in_hands), do: game |> Map.put(:in_hands, in_hands)
  def set_hands(game, hands), do: game |> Map.put(:hands, hands)
  def set_cards(game, cards), do: game |> Map.put(:cards, cards)

  def set_remaining_cards(game, remaining_cards),
    do: game |> Map.put(:remaining_cards, remaining_cards)

  def set_remaining_bets(game, remaining_bets),
    do: game |> Map.put(:remaining_bets, remaining_bets)

  def set_playing_hand(game, playing_hand), do: game |> Map.put(:playing_hand, playing_hand)
  def set_on_table(game, on_table), do: game |> Map.put(:on_table, on_table)
  def set_state(game, state), do: game |> Map.put(:state, state)
  def set_deck_module(game, deck_module), do: game |> Map.put(:deck_module, deck_module)
  def set_result(game, result), do: game |> Map.put(:result, result)

  def get_name(game), do: game |> Map.get(:name)
  def get_players(game), do: game |> Map.get(:players)
  def get_in_hands(game), do: game |> Map.get(:in_hands)
  def get_hands(game), do: game |> Map.get(:hands)
  def get_cards(game), do: game |> Map.get(:cards)
  def get_remaining_cards(game), do: game |> Map.get(:remaining_cards)
  def get_remaining_bets(game), do: game |> Map.get(:remaining_bets)
  def get_playing_hand(game), do: game |> Map.get(:playing_hand)
  def get_on_table(game), do: game |> Map.get(:on_table)
  def get_state(game), do: game |> Map.get(:state)
  def get_deck_module(game), do: game |> Map.get(:deck_module)
  def get_result(game), do: game |> Map.get(:result)

  @doc """
  New Test Game.
  """
  def new_test_game(name), do: new(name) |> set_deck_module(MockDeck)
  def start_joining(game), do: game |> set_state(:join)

  @doc """
  Join Game.
  """
  def join(%__MODULE__{players: players} = game, name) when players |> length < 4 do
    game |> add_player(name) |> add_hand
  end

  def join(%__MODULE__{players: players}, _name) when players |> length == 4,
    do: {:error, :NO_MORE_PLAYERS}

  def player_exists?(game, name), do: game.players |> Enum.any?(&(name == &1.name))

  defp add_player(game, name),
    do: %__MODULE__{game | players: game.players ++ [name |> Player.new()]}

  defp add_hand(game), do: %__MODULE__{game | hands: game.hands + 1}

  @doc """
  Start Game.
  """
  def start(%__MODULE__{players: players}) when players |> length < 2,
    do: {:error, :LESS_PLAYERS}

  def start(game), do: game |> add_hands

  defp add_hands(game) do
    game
    |> set_in_hands(1..game.hands |> Enum.reduce(%{}, &(&2 |> Map.put(&1, Hand.new()))))
    |> set_remaining_bets_to_hands()
  end

  @doc """
  Serve Card.
  """
  def serve({:error, error}), do: {:error, error}

  def serve(game) do
    game
    |> distribute_cards(game.deck_module.serve(game.hands, game.cards))
    |> change_start_hand
    |> start_betting
  end

  defp distribute_cards(game, serve) do
    add_card_function = fn {key, hand} ->
      {key, hand |> Hand.set_cards(serve |> Enum.at(key - 1))}
    end

    game |> update_hands_using(add_card_function)
  end

  defp start_betting(game), do: game |> set_state(:bet)

  def change_start_hand(%__MODULE__{cards: cards, hands: hands} = game) do
    game |> set_playing_hand((cards - 3) |> rem(hands) |> add_one)
  end

  defp add_one(number), do: number + 1

  def next_play_hand(game),
    do: game |> set_playing_hand(1 + (game.playing_hand |> rem(game.hands)))

  def increase_cards(game), do: game |> set_cards(game.cards + 1)
  def set_remaining_cards_to_cards(game), do: game |> set_remaining_cards(game.cards)
  def set_remaining_bets_to_hands(game), do: game |> set_remaining_bets(game.hands)
  # Generic helper
  # TODO move? and add tests for helpers
  def update_hands_using(game, using) do
    new_in_hands = game.in_hands |> Enum.map(using) |> Enum.into(%{})
    %__MODULE__{game | in_hands: new_in_hands}
  end

  def add_card_to_table(game, card), do: game |> set_on_table(game.on_table ++ [card])
  defdelegate fix_next_round_player(game, player), to: __MODULE__, as: :set_playing_hand
  def clear_table(game), do: game |> set_on_table([])

  def reduce_remaining_cards(game),
    do: game |> set_remaining_cards(game.remaining_cards - 1)

  def reduce_remaining_bets(game),
    do: game |> set_remaining_bets(game.remaining_bets - 1)

  def add_expected_bet( #TODO add test for helpers
        %__MODULE__{in_hands: in_hands, playing_hand: playing_hand} = game,
        bet
      ) do
    updated_hand_with_expected_bet = in_hands |> get(playing_hand) |> Hand.set_expected_bet(bet)
    new_in_hands = in_hands |> update_hand_in_hands(playing_hand, updated_hand_with_expected_bet)

    game |> set_in_hands(new_in_hands)
  end

  def update_hand_in_hands(in_hands, player, hand), do: in_hands |> Map.put(player, hand)
  def get(in_hands, player), do: in_hands |> Map.get(player)

  def discard_cards(game) do
    discard_function = fn {key, hand} ->
      {key, hand |> Hand.set_cards(hand.cards |> remove_thrown(game.on_table))}
    end

    game |> update_hands_using(discard_function)
  end

  defp remove_thrown(cards, on_table) do
    cards |> Enum.reject(&(on_table |> Cards.present?(&1)))
  end

  defp get_highest_value_card(cards) do
    cards
    |> Cards.sort()
    |> Enum.reverse()
    |> List.first()
  end

  defp pick_same_face_card_as_first_thrown(cards) do
    first_card = cards |> hd

    cards
    |> Cards.get_same_face_cards_as(first_card)
  end

  def pick_winner_card(cards) do
    {spades, other} = cards |> Cards.split_spades()

    case {spades, other} do
      {[], other} -> other |> pick_same_face_card_as_first_thrown |> get_highest_value_card
      {spades, _other} -> spades |> get_highest_value_card
    end
  end

  def pick_winner(in_hands, winner_card) do
    in_hands
    # |> Enum.find(fn {_key, hand} -> hand.cards |> Enum.any?(&(&1 == winner_card)) end)
    |> Enum.find(fn {_key, hand} -> hand.cards |> Cards.present?(winner_card) end)
    |> player
  end

  defp player({key, _hand}), do: key

  @doc """
  Check whether given player's round is the current round.
  """
  def is_current_player(game, player), do: game.playing_hand == game |> player_index(player)

  defp player_index(game, player),
    do: game.players |> Enum.find_index(&(player == &1.name)) |> add_one

  def player_name(game, index), do: (game.players |> Enum.at(index - 1)).name

  def add_result(game, result), do: %__MODULE__{game | result: result}

  def cards(game, player),
    do:
      game.in_hands[game |> player_index(player)].cards
      |> Enum.reject(fn card -> game.on_table |> Enum.any?(&(card == &1)) end)
      |> Cards.sort()
      |> Enum.map(& &1.name)

  def get_game_state(%__MODULE__{state: state} = game) when state in [:new, :join] do
    %{
      "state" => game.state |> Atom.to_string()
    }
  end

  def get_game_state(game) do
    %{
      "on_table" => game.on_table |> Enum.map(& &1.name),
      "playing_now" => game |> player_name(game.playing_hand),
      "state" => game.state |> Atom.to_string(),
      "cards" => game.cards,
      "result" => game.in_hands |> get_hand(game)
    }
  end

  def get_game_result(game) do
    %{
      "state" => game.state |> Atom.to_string(),
      "points_order" =>
        game.in_hands |> Enum.sort(&points_comparator/2) |> generate_result_hand(game)
    }
  end

  @doc """
  Comparator based on points.
  """
  def points_comparator({_key1, hand1}, {_key2, hand2}), do: hand1.points > hand2.points

  def get_hand(hands, game) do
    hands
    |> Enum.map(fn {player_number, hand} ->
      %{
        player: game.players |> Enum.at(player_number - 1),
        bet: hand.expected_bet,
        current: hand.actual_bet,
        points: hand.points
      }
    end)
  end

  def generate_result_hand(hands, game) do
    hands
    |> Enum.map(fn {player_number, hand} ->
      %{player: game.players |> Enum.at(player_number - 1), points: hand.points}
    end)
  end

  def valid_throw?(game, card) do
    cards_with_player = game.in_hands |> get(game.playing_hand) |> Hand.get_cards()
    cards_on_table = game.on_table
    card |> Validator.valid_throw?(cards_with_player, cards_on_table)
  end
end
