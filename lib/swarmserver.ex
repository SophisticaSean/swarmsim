defmodule Swarmserver do
  use Hound.Helpers
  use GenServer

  @swarm_base "https://swarmsim.github.io/"
  @swarm_all @swarm_base <> "#/tab/all/"

  def init(:ok) do
    Hound.start_session
    navigate_to(@swarm_all)
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
    IO.puts "Server Started"
    {:ok, %{}}
  end

  def handle_cast({:goto_meat}, _from, _nothing) do
    goto_meat
    {:reply, "lol", %{}}
  end

  def goto_meat do
    navigate_to(@swarm_base <> "/#/tab/meat")
  end

  def check_agent_state do
    Agent.get(__MODULE__, fn map -> IO.inspect map end)
  end

  def get_save do
    navigate_to(@swarm_base <> "/#/options")
    case check_for_save_cookie do
    true ->
      save_cookie = get_save_cookie
      Agent.update(__MODULE__, &Map.put(&1, :save_cookie, save_cookie))
      save_cookie
    _ ->
      IO.puts "No saved game, starting fresh"
    end
  end

  def check_for_save_cookie do
    Enum.map(cookies, fn(x) -> x["value"] end)
    |> Enum.any?(fn(x) -> String.length(x) > 100 end)
  end

  def get_save_cookie do
    Enum.filter(cookies, fn(x) -> String.length(x["value"]) > 100 end)
    |> hd
  end
end
