defmodule KpmPhx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kpm_phx,
      version: "0.0.2",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {KpmPhx.Application, []},
      extra_applications: [:logger, :runtime_tools, :corsica]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:corsica, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:chumak, "~> 1.2.0"},
      {:ok, "~> 1.9"},
    ]
  end
end
