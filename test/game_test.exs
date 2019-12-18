defmodule GameTest do
  @moduledoc """
  Game Unit test.
  """
  use ExUnit.Case
  alias Thirteen.{Game, Player, Hand}
  alias Deck.Card

  defp add_players(game, count),
    do: 1..count |> Enum.reduce(game, &(&2 |> Game.join("Player_#{&1}")))

  defp with_hands_and_cards(game, hands, cards),
    do: game |> Game.set_hands(hands) |> Game.set_cards(cards)

  setup_all do
    # cards_on_table = [
    #   Card.new({"AA", 51}),
    #   Card.new({"AC", 38}),
    #   Card.new({"AD", 25})
    # ]

    {:ok, game: Game.new_test_game("Rocket")}
  end

  describe "Game Module" do
    test "Return new game with given name", _state do
      game_name = "Rocket"
      game = Game.new(game_name)
      assert game |> Game.get_name() == game_name
    end

    test "Make player join the game", state do
      old_game_state = state[:game]
      game = old_game_state |> add_players(1)
      assert game |> Game.get_hands() == old_game_state |> Game.get_hands() |> Kernel.+(1)
      assert game |> Game.get_players() |> List.first() == "Player_1" |> Player.new()
    end

    test "Return error when more than 4 players try to join the game", state do
      assert state[:game] |> add_players(5) == {:error, :NO_MORE_PLAYERS}
    end

    test "Check whether a player exist in the game", state do
      game = state[:game] |> Game.join("Sreeni")
      assert game |> Game.player_exists?("Sreeni") == true
      assert game |> Game.player_exists?("Chaitu") == false
    end

    test "Return error when game is started with less than 2 players", state do
      assert state[:game] |> Game.start() == {:error, :LESS_PLAYERS}
    end

    test "Set remaining bets tracking number to the total number of hands(players)", state do
      old_game_state = state[:game]
      game = old_game_state |> add_players(2) |> Game.set_remaining_bets_to_hands()
      assert old_game_state |> Game.get_remaining_bets() == 0
      assert game |> Game.get_remaining_bets() == game |> Game.get_hands()
    end

    test "Starting game adds hands and sets remaining bets to hands", state do
      game = state[:game] |> add_players(2) |> Game.start()

      assert game |> Game.get_in_hands() == %{
               1 => Hand.new(),
               2 => Hand.new()
             }

      assert game |> Game.get_hands() == game |> Game.get_remaining_bets()
    end

    defp cycle_player(players, round),
      do: players |> Enum.at(round |> rem(players |> Enum.count()))

    defp validate_start_hand_for_players(game, count) do
      3..13
      |> Enum.each(fn x ->
        starting_hand = cycle_player(1..count, x - 3)

        assert game
               |> with_hands_and_cards(count, x)
               |> Game.change_start_hand()
               |> Game.get_playing_hand() == starting_hand
      end)
    end

    test "Start hand cycles in a round robin fashion in each round", state do
      game = state[:game]
      validate_start_hand_for_players(game, 2)
      validate_start_hand_for_players(game, 3)
      validate_start_hand_for_players(game, 4)
    end

    test "pipes back error from start if serve is called with error", _state do
      assert Game.serve({:error, :ERROR_FROM_STARTING}) == {:error, :ERROR_FROM_STARTING}
    end

    test "Serving serves cards to players and sets start hand and changes to betting state",
         state do
      game = state[:game] |> add_players(2) |> Game.start() |> Game.serve()
      assert game |> Game.get_playing_hand() == 1
      assert game |> Game.get_state() == :bet

      assert (game |> Game.get_in_hands())[1].cards == [
               Card.new({"2H", 0}),
               Card.new({"3H", 1}),
               Card.new({"4H", 2})
             ]

      assert (game |> Game.get_in_hands())[2].cards == [
               Card.new({"5H", 3}),
               Card.new({"6H", 4}),
               Card.new({"7H", 5})
             ]
    end

    test "Validates next playing hand", state do
      game = state[:game] |> add_players(2) |> Game.start() |> Game.serve()
      assert game |> Game.get_playing_hand() == 1
      game = game |> Game.next_play_hand()
      assert game |> Game.get_playing_hand() == 2
      game = game |> Game.next_play_hand()
      assert game |> Game.get_playing_hand() == 1
      game = state[:game] |> add_players(3) |> Game.start() |> Game.serve()
      assert game |> Game.get_playing_hand() == 1
      game = game |> Game.next_play_hand()
      assert game |> Game.get_playing_hand() == 2
      game = game |> Game.next_play_hand()
      assert game |> Game.get_playing_hand() == 3
      game = game |> Game.next_play_hand()
      assert game |> Game.get_playing_hand() == 1
      game = state[:game] |> add_players(4) |> Game.start() |> Game.serve()
      assert game |> Game.get_playing_hand() == 1
      game = game |> Game.next_play_hand()
      assert game |> Game.get_playing_hand() == 2
      game = game |> Game.next_play_hand()
      assert game |> Game.get_playing_hand() == 3
      game = game |> Game.next_play_hand()
      assert game |> Game.get_playing_hand() == 4
      game = game |> Game.next_play_hand()
      assert game |> Game.get_playing_hand() == 1
    end

    test "Increase cards", state do
      game = state[:game] |> Game.increase_cards()
      assert state[:game] |> Game.get_cards() == 3
      assert game |> Game.get_cards() == 4
    end

    test "Remaining cards in set to number of cards", state do
      game = state[:game] |> Game.increase_cards() |> Game.set_remaining_cards_to_cards()
      assert state[:game] |> Game.get_remaining_cards() == 3
      assert game |> Game.get_cards() == 4
      assert game |> Game.get_remaining_cards() == 4
    end

    test "Adds card to table", state do
      assert state[:game] |> Game.get_on_table() == []
      game = state[:game] |> Game.add_card_to_table(Card.new({"2H", 0}))
      assert game |> Game.get_on_table() == [Card.new({"2H", 0})]
      game = game |> Game.add_card_to_table(Card.new({"AA", 51}))
      assert game |> Game.get_on_table() == [Card.new({"2H", 0}), Card.new({"AA", 51})]
    end

    test "Fix next round Player", state do
      assert state[:game] |> Game.get_playing_hand() == 1
      assert state[:game] |> Game.fix_next_round_player(2) |> Game.get_playing_hand() == 2
      assert state[:game] |> Game.fix_next_round_player(3) |> Game.get_playing_hand() == 3
    end

    test "Clear table", state do
      game = state[:game] |> Game.add_card_to_table(Card.new({"2H", 0}))
      assert game |> Game.get_on_table() == [Card.new({"2H", 0})]
      game = game |> Game.clear_table()
      assert game |> Game.get_on_table() == []
    end

    test "Reduce remaining cards", state do
      game = state[:game] |> Game.set_remaining_cards(3)
      assert game |> Game.get_remaining_cards() == 3
      game = game |> Game.reduce_remaining_cards()
      assert game |> Game.get_remaining_cards() == 2
    end

    test "Reduce remaining bets", state do
      game = state[:game] |> Game.set_remaining_bets(3)
      assert game |> Game.get_remaining_bets() == 3
      game = game |> Game.reduce_remaining_bets()
      assert game |> Game.get_remaining_bets() == 2
    end
  end
end
