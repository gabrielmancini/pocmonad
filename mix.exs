defmodule Pocmonad.MixProject do
  use Mix.Project

  def project do
    [
      app: :pocmonad,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ok, "~> 2.0"},
      {:monadex, "~> 1.1"},
      {:wormhole, "~> 2.2"},
      {:opus, "~> 0.5.1"},
      {:happy, "~> 1.3"}
    ]
  end
end
