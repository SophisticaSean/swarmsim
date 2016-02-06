defmodule Swarmserver do
  use Hound.Helpers
  use GenServer

  @swarm_base "https://swarmsim.github.io/"
  @swarm_all @swarm_base <> "#/tab/all/"

  def init(:ok) do
    Hound.start_session
    navigate_to(@swarm_all)
    IO.puts "Server Started"
    {:ok, %{}}
  end

  def handle_cast({:goto_meat}, _from, nothing) do
    goto_meat
    {:reply, "lol", %{}}
  end

  def goto_meat do
    navigate_to(@swarm_base <> "/#/tab/meat")
  end
end
