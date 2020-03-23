defmodule Textex.Mixfile do
  use Mix.Project

  def project do
    [
      app:             :textex,
      version:         "0.2.2",
      elixir:          "~> 1.2",
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps:            deps(),
      description:     description(),
      package:         package(),
      docs:            [extras: ["README.md", "CHANGELOG.md"]],
      preferred_cli_env: [
        espec:        :test,
        vcr:          :test,
        "vcr.delete": :test,
        "vcr.check":  :test,
        "vcr.show":   :test,
      ],
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

  # PRIVATE ##################################################

  defp description do
    """
    Elixir wrapper around the EZ Texting API.
    """
  end

  defp package do
    [
      maintainers: ["Joshua Rieken", "Matt Roman"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/facto/textex"},
      files: ~w(mix.exs README.md CHANGELOG.md lib),
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
      {:httpoison, "~> 1.6"},
      {:poison,    "~> 3.1"},
      {:espec,     "~> 1.8.1", only: :test},
      {:exvcr,     "~> 0.11", only: :test},
      {:ex_doc,    ">= 0.0.0", only: :dev}
    ]
  end
end
