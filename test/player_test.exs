defmodule PlayerTest do
  @moduledoc """
  Player Unit test.
  """
  use ExUnit.Case
  alias Thirteen.Player

  describe "Player Module" do
    test "Generate a new player" do
      player = Player.new("Chay")
      assert player.name == "Chay"
    end
  end
end
