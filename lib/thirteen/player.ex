defmodule Thirteen.Player do
  @moduledoc """
  Player struct.
  """
  @derive Jason.Encoder
  defstruct name: nil

  @doc """
  New Player.
  """
  def new(name) do
    %__MODULE__{name: name}
  end
end
