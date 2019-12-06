defmodule Thirteen.GameSupervisor do
  @moduledoc """
  Game Supervisor.
  """
  use DynamicSupervisor

  def start_link(_args) do
    IO.puts("Starting Game Supervisor...")
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child(name),
    do: DynamicSupervisor.start_child(__MODULE__, _spec = {Thirteen.Server, name})
  def stop_child(game), do: DynamicSupervisor.terminate_child(__MODULE__, game |> Thirteen.Server.pid)

  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)
end
