defmodule Distro.MixProject do
  use Mix.Project

  def project do
    [
      app: :distro,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer, :wx, :runtime_tools],
      mod: {Distro.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.4.1"},
      {:horde, "~> 0.9.0"},
      {:plug, "~> 1.15"},
      {:cowboy, "~> 2.10"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.6"}
    ]
  end
end
