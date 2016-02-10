# Swarmsim

Uses JS/angular commands to play [swarmsimulator](https://swarmsim.github.io/#/tab/all)

# TODO

Its not very smart right now, would like to make it more strategic.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add swarmsim to your list of dependencies in `mix.exs`:

        def deps do
          [{:swarmsim, "~> 0.0.1"}]
        end

  2. Ensure swarmsim is started before your application:

        def application do
          [applications: [:swarmsim]]
        end

  3. Download and run phantomjs

  4. Pull dependencies into application with mix deps.get

  5. Drop into the application with iex -S mix

  6. Start up the server with Swarmserver.init(:ok)

  7. Make it play with Swarmserver.play

