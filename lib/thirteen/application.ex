defmodule Thirteen.Application do
  @moduledoc """
  Thirteen Application which starts the Supervisor.
  """
  use Application

  def start(_type, _args) do
    IO.puts"Starting Application..."
    Thirteen.Supervisor.start_link([])
  end
end
