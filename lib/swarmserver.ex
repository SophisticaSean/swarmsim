defmodule Swarmserver do
  use Hound.Helpers
  use GenServer

  @swarm_base "https://swarmsim.github.io/"
  @swarm_all @swarm_base <> "#/tab/all/"

  # @unit_list ["drone", "queen", "nest", "greaterqueen", "hive", "swarmling", "stinger", "spider", "mosquito", "locust", "roach", "giantspider", "centipede", "wasp", "devourer", "goon"]

  def init(:ok) do
    Hound.start_session
    navigate_to(@swarm_all)
    config = get_config
    screenshot
    state =
      case config["save_cookie"] do
      nil ->
        IO.puts "No saved game, starting fresh"
        toggle_advanced_data
        # TODO gotta make sure advanced unit data is always on
        Dict.put(config, "save_cookie", get_save)
        |> save_config()
      _ ->
        IO.puts "Save game found"
        IO.puts config["save_cookie"]
        load_save(config["save_cookie"])
        navigate_to(@swarm_base)
        config
      end
    navigate_to(@swarm_all)
    IO.puts "Server Started"
    {:ok, state}
  end

  def play(seconds \\ 5000) do
    ["hatchery", "expansion", "achievementbonus"]
    |> Enum.map(fn(x) -> buy_upgrade(x) end)
    Enum.map(unit_list, fn(x) -> buy_if_under_million(x) end)
    :timer.sleep(10)
    seconds = seconds - 100
    IO.puts seconds
    if seconds > 0 do
      screenshot
      play(seconds)
    end
  end

  def screenshot(open \\ true) do
    take_screenshot("lol.png")
    if open == true do
      System.cmd("open", ["lol.png"])
    end
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

  def unit_list do
    super_scan = fn(a, b) -> Regex.scan(b, a, capture: :all_but_first) end
    find_all_elements(:css, "a.titlecase")
    |> Enum.map(fn(x) ->
        attribute_value(x, "class")
        |> super_scan.(~r/label\-(\w*)/)
        |> List.to_string
       end)
  end

  def buy_unit(unit, amount) do
    execute_script("try{$('body').scope().game._units.byName.#{unit}.buyMax(arguments[0])}catch(e){};", [amount])
    save_game
  end

  def buy_upgrade(upgrade, amount \\ 1) do
    execute_script("try{$('body').scope().game._upgrades.byName.#{upgrade}.buyMax(arguments[0])}catch(e){};", [amount])
    save_game
  end

  def unit_count(unit) do
    execute_script("return $('body').scope().game._units.byName.#{unit}.count().toNumber();")
    |> trunc
  end

  def buy_if_under_million(unit, count \\ 1000000) do
    cur_unit_count = unit_count(unit)
    cond do
      cur_unit_count < count ->
        buy_upgrade("#{unit}twin")
        buy_unit(unit, 0.5)
        IO.puts "buying #{unit}: #{unit_count(unit)}"
      true ->
        true
    end
    buy_upgrade("#{unit}prod")
  end

  def report_unit_count(units \\ unit_list) do
    Enum.map(units, fn(x) ->
      cur_unit_count = unit_count(x)
      IO.puts "#{x}: #{cur_unit_count}"
    end)
  end

  def save_game do
    Dict.put(Map.new, "save_cookie", get_save)
    |> save_config()
  end

  def check_for_save_cookie do
    Enum.map(cookies, fn(x) -> x["value"] end)
    |> Enum.any?(fn(x) -> String.length(x) > 100 end)
  end

  def get_save do
    execute_script("return $('body').scope().game.session.exportSave()")
  end

  def load_save(save) do
    execute_script("$('body').scope().game.session.importSave('#{save}', false)")
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

  def stop do
    Hound.end_session
  end
end
