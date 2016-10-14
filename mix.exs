defmodule Apocryphal.Mixfile do
  use Mix.Project

  def project do
    [app: :apocryphal,
     version: "0.2.7",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Swagger based document driven development for ExUnit",
     package: package,
     deps: deps()]
  end

  def package do
    [
      maintainers: ["Cory O'Daniel"],
      licenses: ["MIT"],
      files: ~w(priv lib mix.exs README.md),
      links: %{"GitHub" => "https://github.com/coryodaniel/apocryphal"}
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
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
    [{:earmark, "~> 1.0.1", only: [:docs, :dev]},
     {:ex_doc, "~> 0.13.0", only: [:docs, :dev]},

     {:mix_test_watch, "~> 0.2", only: :dev},
     {:dogma, "~> 0.1", only: :dev},
     {:credo, "~> 0.4", only: [:dev, :test]},

     {:httpoison, "~> 0.9.0"},
     {:yaml_elixir, "~> 1.1"},
     {:poison, "~> 2.0"},
     {:ex_json_schema, "~> 0.5.1"}]
  end
end
