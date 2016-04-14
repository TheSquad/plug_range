defmodule PlugRange.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_range,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
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
    [
      {:cowboy, "~> 1.0.0"},
      {:plug, "> 0.8.0"},
    ]
  end

  defp description do
  """
  An elixir plug that serves HTTP Range Requests
  """
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md),
      maintainers: ["Morgan Segalis"],
      licenses: ["MIT"],
      links: %{
        "Github" => "http://github.com/TheSquad/plug_range",
      }
    ]
  end
end
