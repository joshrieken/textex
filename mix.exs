defmodule Textex.Mixfile do
  use Mix.Project

  def project do
    [
      app:               :textex,
      version:           "0.1.0",
      elixir:            "~> 1.3",
      build_embedded:    Mix.env == :prod,
      start_permanent:   Mix.env == :prod,
      deps:              deps(),
      preferred_cli_env: [espec: :test],
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [
        :httpoison,
        :logger,
      ],
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:espec,     "~> 0.8.22", only: :test},
    ]
  end
end
