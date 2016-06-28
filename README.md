# Textex

Elixir wrapper for the [Ez Texting](http://www.eztexting.com/developers) SMS API.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `textex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:textex, "~> 0.1.0"}]
    end
    ```

  2. Ensure `textex` is started before your application:

    ```elixir
    def application do
      [applications: [:textex]]
    end
    ```

