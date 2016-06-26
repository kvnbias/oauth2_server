defmodule Oauth2Server.Mixfile do
  use Mix.Project

  def project do
    [app: :oauth2_server,
     version: "0.1.1",
     elixir: "~> 1.2",
     description: "An elixir Oauth 2.0 server",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: escript,
     package: package,
     deps: deps]
  end

  def escript do
    [main_module: Oauth2Server]
  end

  def application do
    [applications: [:logger, :ecto, :comeonin]]
  end

  defp deps do
    [
      {:ecto, "~> 1.1.2"},
      {:poison, "~> 1.5 or ~> 2.0"},
      {:comeonin, "~> 2.4"},
      {:plug, "~> 1.1.6"}
    ]
  end

  defp package do
    [
     maintainers: ["Kevin Baisas"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/kevinbaisas/oauth2_server"},
     files: ~w(lib mix.exs README.md)
   ]
  end
end
