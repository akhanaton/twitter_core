defmodule Twitter.Core.MixProject do
  use Mix.Project

  def project do
    [
      app: :twitter_core,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Twitter.Core.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:timex, "~> 3.6.1"},
      {:elixir_uuid, "~> 1.2.1"},
      {:ex_doc, "~> 0.21.3"},
      {:phoenix_pubsub, "~> 1.1.2"},
      {:ecto_sql, "~> 3.4.1"},
      {:postgrex, ">= 0.0.0"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 0.12.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
