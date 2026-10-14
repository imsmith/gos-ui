defmodule GosUi.Livebook do
  @moduledoc """
  Livebook helpers. Livebook controls its own chrome, so this module does not
  try to theme the page: it hands out the data color as data (for VegaLite /
  Kino charts) and renders self-contained status markup with inline styles,
  always in the **fill** treatment, since the surface is unknown.
  """
  alias GosUi.Tokens
  require Phoenix.LiveViewTest

  @ramp Map.new(Tokens.status().ramp, &{&1.step, &1})
  @lexicon Map.new(Tokens.voice().status_lexicon, &{&1.step, &1})
  @marks Map.new(Tokens.marks().status, &{&1.step, &1})

  @doc """
  Ordered hex list for a chart color range.

      GosUi.Livebook.scale(:spectrum)   # warm pole → green center → cool pole
      GosUi.Livebook.scale(:status)     # critical … unknown
      GosUi.Livebook.scale(:opinion)    # strongly-disagree … strongly-agree
  """
  def scale(:spectrum), do: Enum.map(Tokens.spectrum().stops, & &1.hex24)
  def scale(:status), do: Enum.map(Tokens.status().ramp, & &1.hex24)
  def scale(:opinion), do: Enum.map(Tokens.opinion().map, & &1.hex24)
  def scale(:tlp), do: Enum.map(Tokens.markings().markings, & &1.hex24)

  @doc "Domain labels matching `scale/1`, for an explicit VegaLite `domain`."
  def domain(:spectrum), do: Enum.map(Tokens.spectrum().stops, & &1.index)
  def domain(:status), do: Enum.map(Tokens.status().ramp, &Atom.to_string(&1.step))
  def domain(:opinion), do: Enum.map(Tokens.opinion().map, & &1.value)
  def domain(:tlp), do: Enum.map(Tokens.markings().markings, & &1.name)

  @doc "Status as plain text for logs and terminal cells: `✖ DOWN` (or ASCII with `ascii: true`)."
  def status_text(step, opts \\ []) do
    glyph = if opts[:ascii], do: @marks[step].ascii, else: @marks[step].unicode
    "#{glyph} #{@lexicon[step].display}"
  end

  @doc """
  Self-contained HTML for a status badge (fill treatment, inline styles).
  Wrap with `Kino.HTML.new/1` to render in a cell.
  """
  def status_badge_html(step, opts \\ []) do
    r = @ramp[step]
    word = opts[:label] || @lexicon[step].display
    font = Tokens.typography().families.mono.stack |> Enum.map_join(", ", &~s("#{&1}"))

    ~s(<span style="display:inline-flex;align-items:center;gap:.4em;padding:2px 8px;border-radius:2px;) <>
      ~s(font:500 12px/1.4 #{font};text-transform:uppercase;letter-spacing:.08em;) <>
      ~s(background:#{r.hex24};color:#{r.on_status}" role="status">) <>
      ~s(<span aria-hidden="true">#{@marks[step].unicode}</span>#{word}</span>)
  end

  # The stylesheet, inlined once per output: every token CSS file except fonts
  # (Livebook cannot reach the font files; the stack falls back to system mono).
  @static Path.join([:code.priv_dir(:gos_ui), "static", "gos-ui"])
  @css_files ~w(colors typography spacing effects base components)
  for f <- @css_files, do: @external_resource(Path.join([@static, "tokens", "#{f}.css"]))
  @css Enum.map_join(@css_files, "\n", &File.read!(Path.join([@static, "tokens", "#{&1}.css"])))

  @doc """
  Render any `GosUi.Components` function component as a self-contained HTML
  document fragment: the sprite, the stylesheet, and the markup, on the given
  theme. Returns a `Kino.HTML` when Kino is loaded (pass `kino: false` for
  the raw string).

      GosUi.Livebook.render(&GosUi.Components.heatmap/1, cells: cells, columns: 12)
      GosUi.Livebook.render(&GosUi.Components.sequential_meter/1, value: 82, warn: 70, crit: 90, label: "cpu")
  """
  def render(component, assigns, opts \\ []) when is_function(component, 1) do
    theme = Keyword.get(opts, :theme, :tron)
    mode = Keyword.get(opts, :mode, :dark)
    attrs = GosUi.theme_attrs(theme, mode) |> Enum.map_join(" ", fn {k, v} -> ~s(#{k}="#{v}") end)
    sprite = Phoenix.LiveViewTest.render_component(&GosUi.Components.sprite/1, %{})
    body = Phoenix.LiveViewTest.render_component(component, Map.new(assigns))

    html =
      ~s|<div #{attrs} style="background:var(--bg);color:var(--text);padding:var(--space-2)"><style>#{@css}</style>#{sprite}#{body}</div>|

    if Keyword.get(opts, :kino, true) and Code.ensure_loaded?(Kino),
      do: Kino.HTML.new(html),
      else: html
  end

  if Code.ensure_loaded?(Kino) do
    @doc "`status_badge_html/2` as a `Kino.HTML` output."
    def status_badge(step, opts \\ []), do: Kino.HTML.new(status_badge_html(step, opts))
  end
end
