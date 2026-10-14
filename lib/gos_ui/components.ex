defmodule GosUi.Components do
  @moduledoc """
  HEEx function components. Markup and class names mirror the design system's
  reference React components so both share `tokens/components.css`; every rule
  (status treatment, state matrix, accent-label rule) is enforced by that CSS.
  """
  use Phoenix.Component

  alias GosUi.Tokens

  @sprite_path Path.join([
                 :code.priv_dir(:gos_ui),
                 "static",
                 "gos-ui",
                 "assets",
                 "marks",
                 "sprite.svg"
               ])
  @external_resource @sprite_path
  @sprite File.read!(@sprite_path)
          |> String.replace(~r/<\?xml[^>]*\?>\s*/, "")
          |> String.replace(~r/<svg\s/, ~s(<svg style="display:none" ), global: false)

  @steps Enum.map(Tokens.status().ramp, & &1.step)
  @lexicon Map.new(Tokens.voice().status_lexicon, &{&1.step, &1})

  @doc "Inline the mark sprite once per page (root layout) so `<.mark>` resolves."
  def sprite(assigns) do
    assigns = assign(assigns, :sprite, @sprite)
    ~H"{Phoenix.HTML.raw(@sprite)}"
  end

  @doc "One glyph from the sprite. Inherits `currentColor`. Decorative unless `label` is set."
  attr(:name, :string, required: true, doc: "sprite id, e.g. m-critical")
  attr(:size, :integer, default: 20)
  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def mark(assigns) do
    ~H"""
    <svg
      width={@size}
      height={@size}
      viewBox="0 0 24 24"
      role={if @label, do: "img", else: "presentation"}
      aria-hidden={if @label, do: nil, else: "true"}
      aria-label={@label}
      focusable="false"
      class={@class}
      style="display:inline-block;flex:none;vertical-align:text-bottom"
      {@rest}
    >
      <use href={"##{@name}"} />
    </svg>
    """
  end

  @doc """
  Status badge: alert-ramp color + status glyph + word, driven by one `step`.

  `solid` is the fill treatment (legal everywhere); `soft`/`plain` are outline
  treatments (dark surfaces only). The stylesheet renders every variant as fill
  on `[data-mode="light"]`, and `critical` is always fill.
  """
  attr(:step, :atom, required: true, values: @steps)
  attr(:label, :string, default: nil, doc: "override the display word (DOWN/ALERT/WARN/OK/UNK)")
  attr(:variant, :atom, default: :soft, values: [:soft, :solid, :plain])
  attr(:pulse, :boolean, default: false, doc: "critical/live only")
  attr(:size, :integer, default: 14)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def status_badge(assigns) do
    lex = @lexicon[assigns.step]

    assigns =
      assigns
      |> assign(:word, assigns.label || lex.display)
      |> assign(:glyph, lex.glyph)
      |> assign(:step_name, Atom.to_string(assigns.step))

    ~H"""
    <span
      class={["ds-badge", @variant == :solid && "ds-badge--solid", @variant == :plain && "ds-badge--plain", @pulse && "ds-pulse", @class]}
      data-step={@step_name}
      style={"--_c:var(--status-#{@step_name});--_on:var(--on-status-#{@step_name})"}
      role="status"
      {@rest}
    >
      <.mark name={@glyph} size={@size} label={"#{@step_name} status"} />
      <span>{@word}</span>
    </span>
    """
  end

  @doc """
  Alert / banner keyed to CAP severity. The glyph sits on a fill chip; the left
  rule is non-text reinforcement. Wording: what happened · why · what to do.
  """
  attr(:severity, :atom, default: :info, values: @steps ++ [:info])
  attr(:title, :string, default: nil)
  attr(:pulse, :boolean, default: false)
  attr(:dismiss, :any, default: nil, doc: "phx-click value for the dismiss button; omit for none")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)
  slot(:actions)

  def alert(assigns) do
    sev = Atom.to_string(assigns.severity)

    {c, on, glyph} =
      if assigns.severity == :info,
        do: {"var(--accent)", "var(--on-accent)", "m-info"},
        else:
          {"var(--status-#{sev})", "var(--on-status-#{sev})", @lexicon[assigns.severity].glyph}

    assigns =
      assign(assigns,
        sev: sev,
        style: "--_c:#{c};--_on:#{on}",
        glyph: glyph,
        role: if(assigns.severity in [:critical, :high], do: "alert", else: "status")
      )

    ~H"""
    <div class={["ds-alert", @pulse && "ds-pulse", @class]} style={@style} data-severity={@sev} role={@role} {@rest}>
      <span class="ds-alert__icon"><.mark name={@glyph} size={18} label={@sev} /></span>
      <div class="ds-alert__body">
        <div :if={@title} class="ds-alert__title">{@title}</div>
        <div :if={@inner_block != []} class="ds-alert__msg">{render_slot(@inner_block)}</div>
        <div :if={@actions != []} class="ds-alert__actions">{render_slot(@actions)}</div>
      </div>
      <button :if={@dismiss} type="button" class="ds-alert__x" aria-label="Dismiss" phx-click={@dismiss}>
        <.mark name="m-close" size={16} />
      </button>
    </div>
    """
  end

  @doc """
  Button. `primary` is accent fill (large/heavy label only); `ghost` is the
  body-size action; `danger` is the destructive primary (status/critical fill,
  verb label naming the act).
  """
  attr(:variant, :atom, default: :ghost, values: [:primary, :ghost, :text, :danger])
  attr(:size, :atom, default: :md, values: [:sm, :md, :lg])
  attr(:type, :string, default: "button")
  attr(:icon, :string, default: nil)
  attr(:icon_end, :string, default: nil)
  attr(:loading, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(form name value))
  slot(:inner_block, required: true)

  def button(assigns) do
    assigns = assign(assigns, :icon_size, %{sm: 14, md: 16, lg: 20}[assigns.size])

    ~H"""
    <button
      type={@type}
      class={["ds-btn", "ds-btn--#{@variant}", @size != :md && "ds-btn--#{@size}", @class]}
      disabled={@disabled || @loading}
      aria-busy={if @loading, do: "true"}
      data-loading={if @loading, do: "true"}
      {@rest}
    >
      <span :if={@loading} class="ds-btn__spin" aria-hidden="true"><.mark name="m-refresh" size={@icon_size} /></span>
      <span class="ds-btn__label" style="display:inline-flex;align-items:center;gap:var(--space-1)">
        <.mark :if={@icon} name={@icon} size={@icon_size} />
        {render_slot(@inner_block)}
        <.mark :if={@icon_end} name={@icon_end} size={@icon_size} />
      </span>
    </button>
    """
  end

  @doc "Card / panel: surface container with border and density padding; optional header and footer."
  attr(:title, :string, default: nil)
  attr(:density, :atom, default: :comfortable, values: [:comfortable, :compact, :dense])
  attr(:interactive, :boolean, default: false)
  attr(:selected, :boolean, default: false)
  attr(:flush, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)
  slot(:actions)
  slot(:footer)

  def card(assigns) do
    ~H"""
    <section
      class={["ds-card", @density == :compact && "ds-card--compact", @density == :dense && "ds-card--dense", @interactive && "ds-card--interactive", @selected && "ds-card--selected", @class]}
      tabindex={if @interactive, do: "0"}
      aria-current={if @selected, do: "true"}
      {@rest}
    >
      <header :if={@title || @actions != []} class="ds-card__head">
        <h3 :if={@title} class="ds-card__title">{@title}</h3>
        <div :if={@actions != []} class="ds-card__actions">{render_slot(@actions)}</div>
      </header>
      <div class={["ds-card__body", @flush && "ds-card__body--flush"]}>{render_slot(@inner_block)}</div>
      <footer :if={@footer != []} class="ds-card__foot">{render_slot(@footer)}</footer>
    </section>
    """
  end
end
