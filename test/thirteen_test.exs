defmodule ThirteenTest do
  use ExUnit.Case
  doctest Thirteen

  # describe "Generate a new game" do
  #   test "Returns new game state with the given name" do
  #     name = "rAnDoM_GaMe"
  #     game = Thirteen.new(name)
  #     assert game.name == name
  #     assert game.players == []
  #     assert game.in_hands == []
  #     assert game.hands == 0
  #     assert game.cards == 3
  #     assert game.playing_hand == 1
  #     assert game.on_table == []
  #     assert game.state == :joining
  #   end
  # end

  # describe "Join players" do
  #   test "Join players to the game" do
  #     game = "rAnDoM_GaMe" |> Thirteen.new() |> Thirteen.join("Chaitu")
  #     assert game.players == [%Player{name: "Chaitu"}]
  #     assert game.hands == 1
  #     game = game |> Thirteen.join("Sreeni")
  #     assert game.players == [%Player{name: "Chaitu"}, %Player{name: "Sreeni"}]
  #     assert game.hands == 2
  #   end

  #   test "Returns error when more than 4 players try to join the game" do
  #     assert {:error, :NO_MORE_PLAYERS} =
  #              "rAnDoM_GaMe"
  #              |> Thirteen.new()
  #              |> Thirteen.join("Chaitu")
  #              |> Thirteen.join("Sreeni")
  #              |> Thirteen.join("Riyaz")
  #              |> Thirteen.join("Sasi")
  #              |> Thirteen.join("Boo")
  #   end
  # end

  # describe "Start Game" do
  #   test "Return game with betting state" do
  #     assert ("rAnDoM_GaMe"
  #             |> Thirteen.new()
  #             |> Thirteen.join("Chaitu")
  #             |> Thirteen.join("Sreeni")
  #             |> Thirteen.join("Riyaz")
  #             |> Thirteen.join("Sasi")
  #             |> Thirteen.start()).state == :serving
  #   end

  #   test "Returns error when game is started with less than 2 players" do
  #     assert {:error, :LESS_PLAYERS} ==
  #              "rAnDoM_GaMe"
  #              |> Thirteen.new()
  #              |> Thirteen.join("Chaitu")
  #              |> Thirteen.start()
  #   end

  #   test "Returns error when start is called when game is in state other than joining" do
  #     assert {:error, :ALREADY_STARTED} ==
  #              "rAnDoM_GaMe"
  #              |> Thirteen.new()
  #              |> Thirteen.join("Chaitu")
  #              |> Thirteen.join("Sreeni")
  #              |> Thirteen.start()
  #              |> Thirteen.serve(Deck.new())
  #              |> Thirteen.start()
  #   end
  # end

  # describe "Serve cards" do
  #   test "Serve players with cards" do
  #     game =
  #       "rAnDoM_GaMe"
  #       |> Thirteen.new()
  #       |> Thirteen.join("Chaitu")
  #       |> Thirteen.join("Sreeni")
  #       |> Thirteen.join("Riyaz")
  #       |> Thirteen.join("Sasi")
  #       |> Thirteen.start()
  #       |> Thirteen.serve(Deck.new())

  #     assert game.state == :betting
  #     assert game.in_hands |> Map.keys() |> length == game.hands
  #     assert (game.in_hands |> Map.get(1)).cards |> length == game.cards
  #     assert ((game.in_hands |> Map.get(1)).cards |> Enum.at(0)).name == "2H"
  #     assert ((game.in_hands |> Map.get(1)).cards |> Enum.at(1)).name == "3H"
  #   end

  #   test "Returns new Game with specified hands but with a shuffled deck" do
  #     game =
  #       "rAnDoM_GaMe"
  #       |> Thirteen.new()
  #       |> Thirteen.join("Chaitu")
  #       |> Thirteen.join("Sreeni")
  #       |> Thirteen.join("Riyaz")
  #       |> Thirteen.join("Sasi")
  #       |> Thirteen.start()
  #       |> Thirteen.serve(Deck.new())

  #     assert game.state == :betting
  #     assert game.in_hands |> Map.keys() |> length == game.hands
  #     assert (game.in_hands |> Map.get(1)).cards |> length == game.cards
  #   end
  # end

  # describe "Place bet" do
  #   test "Place bet by the two players" do
  #     game =
  #       "rAnDoM_GaMe"
  #       |> Thirteen.new()
  #       |> Thirteen.join("Chaitu")
  #       |> Thirteen.join("Sasi")
  #       |> Thirteen.start()
  #       |> Thirteen.serve(Deck.new())

  #     game = game |> Thirteen.place_bet(1)
  #     assert (game.in_hands |> Map.get(1)).expected_bet == 1
  #     assert game.playing_hand == 2
  #     assert game.state == :betting
  #     game = game |> Thirteen.place_bet(2)
  #     assert (game.in_hands |> Map.get(2)).expected_bet == 2
  #     assert game.playing_hand == 1
  #     assert game.state == :throw_card
  #   end

  #   test "Returns error when the game state is not in betting mode" do
  #     assert {:error, :NO_BETTING} ==
  #              "rAnDoM_GaMe"
  #              |> Thirteen.new()
  #              |> Thirteen.place_bet(1)
  #   end
  # end

  # describe "Throw card" do
  #   test "Throw cards for the round" do
  #     game =
  #       "rAnDoM_GaMe"
  #       |> Thirteen.new()
  #       |> Thirteen.join("Sreeni")
  #       |> Thirteen.join("Riyaz")
  #       |> Thirteen.start()
  #       |> Thirteen.serve(Deck.new())
  #       |> Thirteen.place_bet(1)
  #       |> Thirteen.place_bet(1)

  #     game = game |> Thirteen.throw_card("2H")
  #     assert (game.on_table |> Enum.at(0)).name == "2H"
  #     game = game |> Thirteen.throw_card("6H")
  #     assert (game.on_table |> Enum.at(1)).name == "6H"
  #   end

  #   test "Return error when the game state is not in throw_card mode" do
  #     assert {:error, :NO_THROW_CARD} ==
  #              "rAnDoM_GaMe"
  #              |> Thirteen.new()
  #              |> Thirteen.throw_card(1)
  #   end
  # end

  # describe "Choose winner" do
  # @tag winner: true
  #   test "choose spade" do
  #     assert Thirteen.winner(["2H", "3D", "4C", "AA"]) == "AA"
  #   end
  # @tag winner: true
  #   test "choose bigger spade" do
  #     assert Thirteen.winner(["2H", "3D", "KA", "AA"]) == "AA"
  #   end
  # @tag winner: true
  #   test "choose bigger first card if spade is not thrown" do
  #     assert Thirteen.winner(["2H", "4H", "KC", "AC"]) == "4H"
  #   end
  # @tag winner: true
  #   test "choose first card if spade is not thrown and first card is the biggest" do
  #     assert Thirteen.winner(["KH", "4H", "KC", "AC"]) == "KH"
  #   end
  # @tag winner: true
  #   test "choose bigger spade card if spade is the first card" do
  #     assert Thirteen.winner(["AA", "4H", "KC", "KA"]) == "AA"
  #   end
  # end
end
