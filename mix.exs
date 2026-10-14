defmodule GosUi.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source "https://github.com/imsmith/gos-ui"

  def project do
    [
      app: :gos_ui,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description:
        "GRID·OPS design-system components for Phoenix LiveView and Livebook — " <>
          "a BEAM consumer of imsmith/design-system.",
      package: [
        licenses: ["AGPL-3.0-or-later"],
        links: %{
          "GitHub" => @source,
          "Design system" => "https://github.com/imsmith/design-system"
        },
        files: ~w(lib priv mix.exs README.md LICENSE.md)
      ]
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      {:phoenix_live_view, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:kino, "~> 0.14", optional: true}
    ]
  end
end
