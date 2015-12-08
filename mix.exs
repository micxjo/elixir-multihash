defmodule Multihash.Mixfile do
  use Mix.Project

  def project do
    [app: :multihash,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/micxjo/elixir-multihash",
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:hexate, ">= 0.5.0", only: :test},
     {:dogma, "~> 0.0", only: :dev},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}]
  end
end
