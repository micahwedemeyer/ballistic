defmodule Ballistic.Mixfile do
  use Mix.Project

  def project do
    [app: :ballistic,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env)
   ]
  end

  # This makes sure your factory and any other modules in test/support are compiled
  # when in the test environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger, :slack, :gproc, :poison, :hulaaki, :websocket_client, :postgrex],
      mod: {Ballistic, []}
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
      {:hulaaki, "~> 0.0.4"},
      {:slack, "~> 0.8.0"},
      {:poison, "~> 2.0"},
      {:gproc, "~> 0.6.1"},
      {:postgrex, "~> 0.12.0"},
      {:ecto, "~> 2.0.0"},

      # Test
      {:ex_machina, "~> 1.0", only: :test},

      # Deployment
      {:distillery, "~> 1.0"}
    ]
  end
end
