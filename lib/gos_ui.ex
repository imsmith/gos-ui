defmodule GosUi do
  @moduledoc """
  GRID·OPS design-system components for the BEAM.

  A consumer of [imsmith/design-system](https://github.com/imsmith/design-system):
  the manual is the authority for meaning, the `edn` tokens for values. This
  library vendors the generated serializations (`priv/static/gos-ui/` and
  `GosUi.Tokens`) and provides HEEx function components plus Livebook helpers.

  ## Phoenix

  Serve `priv/static/gos-ui` and link the stylesheet from your root layout:

      <link rel="stylesheet" href={~p"/gos-ui/styles.css"} />

  Then `use GosUi` in your view module (or `import GosUi.Components`) and put
  `<.sprite />` once in the layout so `<.mark>` can resolve `#m-…` ids.
  """

  defmacro __using__(_opts) do
    quote do
      import GosUi.Components
    end
  end

  @doc "Path to the vendored static root (serve it at `/gos-ui`)."
  def static_path, do: Application.app_dir(:gos_ui, "priv/static/gos-ui")

  @themes Enum.map(GosUi.Tokens.themes().themes, fn {k, _} -> k end)
  @modes [:dark, :light]

  @doc "Theme identities from the tokens: `#{inspect(@themes)}`."
  def themes, do: @themes

  @doc """
  Attributes that select a theme and mode, for the `<html>` or `<body>` tag.
  Dark is the default and needs no mode attribute.

      <html {GosUi.theme_attrs(@theme, @mode)}>
  """
  def theme_attrs(theme \\ :tron, mode \\ :dark) when theme in @themes and mode in @modes do
    [{"data-theme", Atom.to_string(theme)}] ++
      if(mode == :light, do: [{"data-mode", "light"}], else: [])
  end
end
