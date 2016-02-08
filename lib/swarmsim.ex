defmodule Swarmsim do
  use Hound.Helpers
  use GenServer

  ## Client API

  @swarm "https://swarmsim.github.io/"

  def start_link do
    GenServer.start_link(Swarmserver, :ok, name: Swarmserver)
  end

  def state do
    GenServer.call(Swarmserver, :get_state)
  end

  def call(atom) do
    GenServer.call(Swarmserver, atom)
  end
end
