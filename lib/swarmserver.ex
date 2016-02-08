defmodule Swarmserver do
  use Hound.Helpers
  use GenServer

  @swarm_base "https://swarmsim.github.io/"
  @swarm_all @swarm_base <> "#/tab/all/"

  def init(:ok) do
    Hound.start_session
    navigate_to(@swarm_all)
    config = get_config
    state =
      case config["save_cookie"] do
      nil ->
        IO.puts "No saved game, starting fresh"
        toggle_advanced_data
        # TODO gotta make sure advanced unit data is always on
        Dict.put(config, "save_cookie", get_save_cookie)
        |> save_config()
      _ ->
        IO.puts "Save game found"
        load_save_cookie(config["save_cookie"])
        navigate_to(@swarm_base)
        config
      end
    navigate_to(@swarm_all)
    IO.puts "Server Started"
    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def toggle_advanced_data do
    navigate_to(@swarm_base <> "/#/options")
    # have to make a change to initial gamestate to generate a save cookie
    find_element(:xpath, "//label/input[@ng-model='form.showadvancedunitdata']")
    |> click
  end

  def buy_unit(unit, amount) do
    execute_script("$('body').scope().game._units.byName.#{unit}.buyMax(arguments[0])", [amount])
    save_game
  end

  def buy_upgrade(upgrade, amount \\ 1) do
    execute_script("$('body').scope().game._upgrades.byName.#{upgrade}.buyMax(arguments[0])", [amount])
    save_game
  end

  def unit_count(unit) do
    execute_script("return $('body').scope().game._units.byName.#{unit}.count().c[0];")
  end

  def save_game do
    state = Dict.put(Map.new, "save_cookie", get_save_cookie)
    |> save_config()
  end

  def check_for_save_cookie do
    Enum.map(cookies, fn(x) -> x["value"] end)
    |> Enum.any?(fn(x) -> String.length(x) > 100 end)
  end

  def get_save_cookie do
    temp = Enum.filter(cookies, fn(x) -> String.length(x["value"]) > 100 end)
    hd temp
  end

  def load_save_cookie(save) do
    set_cookie(save)
  end

  def get_config do
    env_json = File.read("config/config.json")
    case env_json do
      {:error, :enoent} ->
        File.write("config/config.json", "{}")
        Map.new()
      _ ->
        env_json = elem(env_json, 1)
        elem(JSX.decode(env_json), 1)
    end
  end

  def push_config(key, value) do
    env_dict = get_config
    |> Dict.put(key, value)
    |> JSX.encode
    File.write("config/config.json", env_dict)
  end

  def save_config(state) do
    env_dict = get_config
    state = Enum.into(state, env_dict)
    to_save = JSX.encode(state)
    |> elem(1)
    File.write("config/config.json", to_save)
    state
  end

  def clear_config do
    File.write("config/config.json", "{}")
  end
end
