defmodule Thirteen.Supervisor do
  @moduledoc """
  App supervisor supervising registry and game supervisor.
  """
  use Supervisor

  def start_link(_args) do
    IO.puts "Starting Supervisor..."
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Thirteen.GameSupervisor, []},
      {Registry, keys: :unique, name: :game_registry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
