defmodule Swarmsim do
  use Hound.Helpers
  use GenServer

  ## Client API

  @swarm "https://swarmsim.github.io/"

  def start_link do
    GenServer.start_link(Swarmserver, :ok, name: Swarmserver)
  end

  def goto do
    GenServer.call(Swarmserver, {:goto_meat})
  end
end
