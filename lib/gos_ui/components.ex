defmodule GosUi.Components do
  @moduledoc """
  HEEx function components. Markup and class names mirror the design system's
  reference React components so both share `tokens/components.css`; every rule
  (status treatment, state matrix, accent-label rule) is enforced by that CSS.
  """
  use Phoenix.Component

  alias GosUi.Tokens
  alias Phoenix.LiveView.JS

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
  on `[data-mode="light"]`.
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

  # ---------------------------------------------------------------- Tag

  @doc "Neutral metadata chip (chrome color, never status). `remove` = phx-click value for a dismiss button."
  attr(:icon, :string, default: nil)
  attr(:accent, :boolean, default: false)
  attr(:remove, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def tag(assigns) do
    ~H"""
    <span class={["ds-tag", @accent && "ds-tag--accent", @class]} {@rest}>
      <.mark :if={@icon} name={@icon} size={12} />
      <span>{render_slot(@inner_block)}</span>
      <button :if={@remove} type="button" class="ds-tag__x" aria-label="Remove" phx-click={@remove}>
        <.mark name="m-close" size={12} />
      </button>
    </span>
    """
  end

  # ------------------------------------------------------- Data: meters

  @stops Map.new(Tokens.spectrum().stops, &{&1.index, "var(--spectrum-#{&1.name})"})
  @stop_min Tokens.spectrum().stops |> Enum.map(& &1.index) |> Enum.min()
  @stop_max Tokens.spectrum().stops |> Enum.map(& &1.index) |> Enum.max()

  @doc false
  def spectrum_stop(v) do
    @stops[v |> round() |> max(@stop_min) |> min(@stop_max)]
  end

  defp fmt(n) when is_float(n), do: :erlang.float_to_binary(n, [:compact, decimals: 2])
  defp fmt(n), do: to_string(n)

  @doc """
  Diverging meter: signed deviation from a green center, colored by the
  spectrum stop at the signed magnitude. The signed number and diverging mark
  are always shown, so the value reads without color.
  """
  attr(:value, :any, required: true, doc: "signed number; 0 = nominal")
  attr(:range, :any, default: 5, doc: "max absolute magnitude for scaling")
  attr(:label, :string, default: nil)
  attr(:unit, :string, default: "")
  attr(:show_value, :boolean, default: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def diverging_meter(assigns) do
    v = assigns.value
    clamped = v |> max(-assigns.range) |> min(assigns.range)
    half = abs(clamped) / assigns.range * 50
    positive = clamped > 0
    zero = round(clamped) == 0

    assigns =
      assign(assigns,
        color: spectrum_stop(clamped),
        glyph:
          cond do
            zero -> "m-neutral"
            positive -> "m-warm"
            true -> "m-cool"
          end,
        glyph_label:
          cond do
            zero -> "neutral"
            positive -> "over"
            true -> "under"
          end,
        sign_str:
          cond do
            zero -> "±0"
            positive -> "+#{fmt(abs(v))}"
            true -> "−#{fmt(abs(v))}"
          end,
        width: "#{fmt(half)}%",
        left: if(positive, do: "50%", else: "#{fmt(50 - half)}%")
      )

    ~H"""
    <div class={["ds-dmeter", @class]} {@rest}>
      <div class="ds-dmeter__top">
        <span :if={@label} class="ds-dmeter__label">{@label}</span>
        <span :if={@show_value} class="ds-dmeter__val" style={"--_c:#{@color}"}>
          <.mark name={@glyph} size={14} label={@glyph_label} />
          <span>{@sign_str}{@unit}</span>
        </span>
      </div>
      <div class="ds-dmeter__track" role="meter" aria-valuenow={@value} aria-valuemin={-@range} aria-valuemax={@range} aria-label={@label}>
        <div class="ds-dmeter__center" aria-hidden="true"></div>
        <div class="ds-dmeter__fill" style={"--_c:#{@color};width:#{@width};left:#{@left}"}></div>
      </div>
    </div>
    """
  end

  @doc """
  Sequential meter: 0→max with optional warn/crit thresholds. Accent fill; on
  crossing a threshold the fill and value adopt the alert-ramp color and the
  state is echoed in words. Never the spectrum.
  """
  attr(:value, :any, required: true)
  attr(:max, :any, default: 100)
  attr(:warn, :any, default: nil)
  attr(:crit, :any, default: nil)
  attr(:label, :string, default: nil)
  attr(:unit, :string, default: "%")
  attr(:show_value, :boolean, default: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def sequential_meter(assigns) do
    {color, word} = threshold_state(assigns.value, assigns.warn, assigns.crit)
    pct = (assigns.value / assigns.max * 100) |> max(0) |> min(100)
    tick = fn t -> "left:#{fmt(t / assigns.max * 100)}%" end

    assigns =
      assign(assigns,
        color: color,
        word: word,
        width: "#{fmt(pct)}%",
        warn_style: assigns.warn && tick.(assigns.warn),
        crit_style: assigns.crit && tick.(assigns.crit)
      )

    ~H"""
    <div class={["ds-meter", @class]} {@rest}>
      <div class="ds-meter__top">
        <span :if={@label} class="ds-meter__label">{@label}</span>
        <span :if={@show_value} class="ds-meter__val" style={"--_c:#{@color}"}>
          <span>{fmt(@value)}{@unit}</span>
          <span :if={@word} class="ds-meter__word">{@word}</span>
        </span>
      </div>
      <div class="ds-meter__track" role="meter" aria-valuenow={@value} aria-valuemin="0" aria-valuemax={@max} aria-label={@label}>
        <div class="ds-meter__fill" style={"width:#{@width};--_c:#{@color}"}></div>
        <div :if={@warn_style} class="ds-meter__tick ds-meter__tick--warn" style={@warn_style}></div>
        <div :if={@crit_style} class="ds-meter__tick ds-meter__tick--crit" style={@crit_style}></div>
      </div>
    </div>
    """
  end

  defp threshold_state(value, warn, crit) do
    cond do
      crit && value >= crit -> {"var(--status-critical)", "CRIT"}
      warn && value >= warn -> {"var(--status-medium)", "WARN"}
      true -> {"var(--accent)", nil}
    end
  end

  @doc """
  Sparkline: compact axis-less trend, latest point marked and labelled. `plain`
  is a neutral accent series; `threshold` adopts the alert ramp when the last
  value crosses warn/crit (thresholds drawn as dashed lines).
  """
  attr(:data, :list, required: true)
  attr(:width, :integer, default: 96)
  attr(:height, :integer, default: 24)
  attr(:mode, :atom, default: :plain, values: [:plain, :threshold])
  attr(:warn, :any, default: nil)
  attr(:crit, :any, default: nil)
  attr(:unit, :string, default: "")
  attr(:show_end, :boolean, default: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def sparkline(assigns) do
    %{data: data, width: w, height: h} = assigns
    n = length(data)
    {mn, mx} = if n > 0, do: Enum.min_max(data), else: {0, 0}
    span = if mx - mn == 0, do: 1, else: mx - mn
    pad = 2
    y = fn v -> h - pad - (v - mn) / span * (h - pad * 2) end

    pts =
      data
      |> Enum.with_index()
      |> Enum.map(fn {v, i} ->
        {if(n <= 1, do: 0, else: i / (n - 1) * (w - pad * 2) + pad), y.(v)}
      end)

    path =
      pts
      |> Enum.with_index()
      |> Enum.map_join(" ", fn {{x, py}, i} ->
        "#{if i == 0, do: "M", else: "L"}#{fmt1(x)},#{fmt1(py)}"
      end)

    last = List.last(data)

    {color, word} =
      if assigns.mode == :threshold and last != nil,
        do: threshold_state(last, assigns.warn, assigns.crit),
        else: {"var(--accent)", nil}

    {ex, ey} = List.last(pts) || {0, 0}

    assigns =
      assign(assigns,
        path: path,
        last: last,
        color: color,
        word: word,
        end_x: fmt1(ex),
        end_y: fmt1(ey),
        warn_y: assigns.mode == :threshold && assigns.warn && fmt1(y.(assigns.warn)),
        crit_y: assigns.mode == :threshold && assigns.crit && fmt1(y.(assigns.crit))
      )

    ~H"""
    <span class={["ds-spark", @class]} {@rest}>
      <svg class="ds-spark__svg" width={@width} height={@height} viewBox={"0 0 #{@width} #{@height}"} aria-hidden="true">
        <line :if={@warn_y} x1="0" y1={@warn_y} x2={@width} y2={@warn_y} stroke="var(--status-medium)" stroke-width="1" stroke-dasharray="2 2" opacity="0.7" />
        <line :if={@crit_y} x1="0" y1={@crit_y} x2={@width} y2={@crit_y} stroke="var(--status-critical)" stroke-width="1" stroke-dasharray="2 2" opacity="0.7" />
        <path d={@path} fill="none" stroke={@color} stroke-width="1.5" stroke-linejoin="round" stroke-linecap="round" />
        <circle :if={@last != nil} cx={@end_x} cy={@end_y} r="2.2" fill={@color} />
      </svg>
      <span :if={@show_end && @last != nil} class="ds-spark__end" style={"--_c:#{@color}"}>
        <span>{fmt(@last)}{@unit}</span>
        <span :if={@word} class="ds-spark__word">{@word}</span>
      </span>
    </span>
    """
  end

  defp fmt1(n), do: :erlang.float_to_binary(n / 1, decimals: 1)

  @doc """
  Heatmap: status-at-scale grid. Each cell is a spectrum stop by its deviation
  from green. The legend is mandatory; every cell carries its value as title
  and accessible name; critical-end cells carry the m-critical glyph.
  `select` = phx-click event; the cell sends `phx-value-id`.
  """
  attr(:cells, :list, required: true, doc: "maps with :value and optional :id, :label, row-major")
  attr(:columns, :integer, default: nil)
  attr(:range, :any, default: 5)
  attr(:critical_at, :any, default: 4)
  attr(:unit, :string, default: "")
  attr(:select, :any, default: nil)
  attr(:show_legend, :boolean, default: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def heatmap(assigns) do
    n = length(assigns.cells)
    cols = assigns.columns || max(1, n |> :math.sqrt() |> Float.ceil() |> trunc())

    cells =
      assigns.cells
      |> Enum.with_index()
      |> Enum.map(fn {c, i} ->
        v = c[:value] || 0

        sign =
          cond do
            v > 0 -> "+"
            v < 0 -> "−"
            true -> "±"
          end

        name = c[:label] || c[:id] || i

        %{
          id: c[:id] || i,
          title: "#{name}: #{sign}#{fmt(abs(v))}#{assigns.unit}",
          color: spectrum_stop(v),
          crit?: v >= assigns.critical_at
        }
      end)

    assigns = assign(assigns, cols: cols, cell_data: cells)

    ~H"""
    <div class={["ds-heat", @class]} {@rest}>
      <div class="ds-heat__grid" style={"grid-template-columns:repeat(#{@cols}, minmax(0,1fr))"}>
        <button
          :for={c <- @cell_data}
          type="button"
          class="ds-heat__cell"
          style={"background:#{c.color}"}
          title={c.title}
          aria-label={c.title}
          phx-click={@select}
          phx-value-id={@select && c.id}
        >
          <.mark :if={c.crit?} name="m-critical" size={12} />
        </button>
      </div>
      <div :if={@show_legend} class="ds-heat__legend" aria-hidden="true">
        <span class="ds-heat__legend-end">cool −{@range}</span>
        <span class="ds-heat__bar"></span>
        <span class="ds-heat__legend-end">warm +{@range}</span>
        <span class="ds-heat__crit"><.mark name="m-critical" size={12} /> crit</span>
      </div>
    </div>
    """
  end

  # ------------------------------------------------------------- Forms

  @input_attrs ~w(name value type placeholder autocomplete disabled readonly required min max step pattern maxlength minlength form list inputmode checked)

  @doc "Checkbox: checked = accent box with the m-low check glyph, so the state reads without color."
  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: @input_attrs)

  def checkbox(assigns) do
    ~H"""
    <label class={["ds-check", @class]}>
      <input type="checkbox" class="ds-check__input" {@rest} />
      <span class="ds-check__box" aria-hidden="true"><.mark name="m-low" size={14} class="ds-check__mark" /></span>
      <span :if={@label}>{@label}</span>
    </label>
    """
  end

  @doc """
  Text field: caption label, mono field, helper or error text. Error is
  critical border + m-critical glyph + message — color + glyph + text.
  """
  attr(:label, :string, default: nil)
  attr(:icon, :string, default: nil)
  attr(:error, :string, default: nil)
  attr(:helper, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: @input_attrs)

  def input(assigns) do
    assigns =
      assign(assigns,
        fid: field_id(assigns.id, assigns.label),
        msg: assigns.error || assigns.helper
      )

    ~H"""
    <div class={["ds-field", @error && "ds-field--error", @class]}>
      <label :if={@label} class="ds-field__label" for={@fid}>{@label}</label>
      <div class="ds-field__wrap">
        <span :if={@icon} class="ds-field__icon"><.mark name={@icon} size={16} /></span>
        <input id={@fid} class={["ds-input", @icon && "ds-input--has-icon"]} aria-invalid={if @error, do: "true"} {@rest} />
      </div>
      <div :if={@msg} class="ds-field__msg">
        <.mark :if={@error} name="m-critical" size={12} label="Error" />
        <span>{@msg}</span>
      </div>
    </div>
    """
  end

  @doc """
  Select: native `<select>` styled to match the input, trailing m-chevron.
  `options` are strings or `{label, value}` tuples; or pass `<option>`s as content.
  """
  attr(:label, :string, default: nil)
  attr(:options, :list, default: [])
  attr(:value, :any, default: nil, doc: "selected value")
  attr(:error, :string, default: nil)
  attr(:helper, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(name disabled required form multiple))
  slot(:inner_block)

  def select(assigns) do
    opts =
      Enum.map(assigns.options, fn
        {l, v} -> {l, v}
        o -> {o, o}
      end)

    assigns =
      assign(assigns,
        fid: field_id(assigns.id, assigns.label),
        msg: assigns.error || assigns.helper,
        opts: opts
      )

    ~H"""
    <div class={["ds-field", @error && "ds-field--error", @class]}>
      <label :if={@label} class="ds-field__label" for={@fid}>{@label}</label>
      <div class="ds-select__wrap">
        <select id={@fid} class="ds-select" aria-invalid={if @error, do: "true"} {@rest}>
          {render_slot(@inner_block)}
          <option :for={{l, v} <- @opts} value={v} selected={to_string(v) == to_string(@value)}>{l}</option>
        </select>
        <span class="ds-select__chevron"><.mark name="m-chevron" size={16} /></span>
      </div>
      <div :if={@msg} class="ds-field__msg">
        <.mark :if={@error} name="m-critical" size={12} label="Error" />
        <span>{@msg}</span>
      </div>
    </div>
    """
  end

  defp field_id(id, _label) when is_binary(id), do: id
  defp field_id(nil, nil), do: nil

  defp field_id(nil, label),
    do: "ds-" <> (label |> String.downcase() |> String.replace(~r/\s+/, "-"))

  @doc "Toggle switch: the knob position carries the state, not just color. `show_state` adds ON/OFF text."
  attr(:label, :string, default: nil)
  attr(:checked, :boolean, default: false)
  attr(:show_state, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(name value disabled form))

  def toggle(assigns) do
    ~H"""
    <label class={["ds-toggle", @class]}>
      <input type="checkbox" role="switch" class="ds-toggle__input" checked={@checked} {@rest} />
      <span class="ds-toggle__track" aria-hidden="true"><span class="ds-toggle__knob"></span></span>
      <span :if={@show_state} class="ds-toggle__state">{if @checked, do: "ON", else: "OFF"}</span>
      <span :if={@label}>{@label}</span>
    </label>
    """
  end

  # -------------------------------------------------------------- Tabs

  @doc """
  Tab row: selected = accent underline + text, others muted. Server-driven:
  `active` is the selected id and `select` the phx-click event (gets `phx-value-id`).
  """
  attr(:tabs, :list,
    required: true,
    doc: "maps with :id, :label and optional :icon, :count, :disabled"
  )

  attr(:active, :any, default: nil, doc: "selected id; defaults to the first tab")
  attr(:select, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def tabs(assigns) do
    active = assigns.active || (List.first(assigns.tabs) || %{})[:id]
    assigns = assign(assigns, :active_id, active)

    ~H"""
    <div class={["ds-tabs", @class]} {@rest}>
      <div class="ds-tabs__list" role="tablist">
        <button
          :for={t <- @tabs}
          type="button"
          role="tab"
          class="ds-tab"
          aria-selected={if t.id == @active_id, do: "true", else: "false"}
          disabled={t[:disabled]}
          phx-click={@select}
          phx-value-id={@select && t.id}
        >
          <.mark :if={t[:icon]} name={t[:icon]} size={14} />
          <span>{t.label}</span>
          <span :if={t[:count]} class="ds-tab__count">{t[:count]}</span>
        </button>
      </div>
    </div>
    """
  end

  # ------------------------------------------------------------- Table

  @doc """
  Table: the workhorse. Caption header, density modes, numeric columns
  right-aligned in tabular mono, sortable headers with a chevron, selected row
  as accent tint + left rule. Define its empty/loading/error states with
  `state_panel/1`.

      <.table rows={@nodes} row_id={& &1.id} selected={@sel} on_select="pick" sort={@sort} on_sort="sort" density={:compact}>
        <:col :let={n} key="id" label="Node" sortable>{n.id}</:col>
        <:col :let={n} key="step" label="Status"><.status_badge step={n.step} variant={:plain} size={13} /></:col>
        <:col :let={n} key="cpu" label="CPU %" num sortable>{n.cpu}</:col>
      </.table>
  """
  attr(:rows, :list, required: true)
  attr(:row_id, :any, default: nil, doc: "fun row -> id; defaults to row.id or row[:id]")
  attr(:density, :atom, default: :comfortable, values: [:comfortable, :compact, :dense])
  attr(:sort, :map, default: nil, doc: "%{key: \"cpu\", dir: :ascending | :descending}")
  attr(:on_sort, :any, default: nil, doc: "phx-click event; sends phx-value-key")
  attr(:selected, :any, default: nil, doc: "selected row id")
  attr(:on_select, :any, default: nil, doc: "phx-click event; sends phx-value-id")
  attr(:caption, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot :col, required: true do
    attr(:key, :string)
    attr(:label, :string)
    attr(:num, :boolean)
    attr(:sortable, :boolean)
  end

  def table(assigns) do
    row_id = assigns.row_id || fn r -> r[:id] end
    assigns = assign(assigns, :id_of, row_id)

    ~H"""
    <table class={["ds-table", @density != :comfortable && "ds-table--#{@density}", @class]} {@rest}>
      <caption :if={@caption} class="ds-table__caption">{@caption}</caption>
      <thead>
        <tr>
          <th
            :for={col <- @col}
            scope="col"
            class={["ds-table__th", col[:num] && "ds-table__th--num"]}
            aria-sort={sort_state(@sort, col)}
          >
            <button :if={col[:sortable]} type="button" class="ds-table__sort" phx-click={@on_sort} phx-value-key={col[:key]}>
              <span>{col[:label]}</span><.mark name="m-chevron" size={12} />
            </button>
            <%= if !col[:sortable], do: col[:label] %>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          :for={row <- @rows}
          class={["ds-table__row", @on_select && "ds-table__row--interactive"]}
          aria-selected={@on_select && to_string(@selected != nil and @selected == @id_of.(row))}
          tabindex={@on_select && "0"}
          phx-click={@on_select}
          phx-value-id={@on_select && @id_of.(row)}
        >
          <td :for={col <- @col} class={["ds-table__td", col[:num] && "ds-table__td--num"]}>{render_slot(col, row)}</td>
        </tr>
      </tbody>
    </table>
    """
  end

  defp sort_state(%{key: k, dir: d}, %{key: k}), do: to_string(d)
  defp sort_state(_, col), do: if(col[:sortable], do: "none")

  # ------------------------------------------------ Empty / loading / error

  @state_modes %{
    empty: {"m-unknown", "status"},
    loading: {"m-refresh", "status"},
    error: {"m-critical", "alert"}
  }

  @doc """
  The empty / loading / error triad every data view must define. Empty says
  why and offers the next action; loading sets aria-busy; error is the glyph
  on a fill chip + plain-language message + retry.
  """
  attr(:mode, :atom, default: :empty, values: [:empty, :loading, :error])
  attr(:mark, :string, default: nil)
  attr(:title, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)
  slot(:action)

  def state_panel(assigns) do
    {mark, role} = @state_modes[assigns.mode]

    assigns =
      assign(assigns,
        mark: assigns.mark || mark,
        role: role,
        mode_name: Atom.to_string(assigns.mode)
      )

    ~H"""
    <div class={["ds-state", "ds-state--#{@mode_name}", @class]} role={@role} aria-busy={if @mode == :loading, do: "true"} {@rest}>
      <span class="ds-state__mark"><.mark name={@mark} size={24} label={@mode_name} /></span>
      <div :if={@title} class="ds-state__title">{@title}</div>
      <div :if={@inner_block != []} class="ds-state__msg">{render_slot(@inner_block)}</div>
      <div :if={@action != []} class="ds-state__action">{render_slot(@action)}</div>
    </div>
    """
  end

  @doc "Muted surface blocks standing in for loading content."
  attr(:lines, :integer, default: 3)
  attr(:width, :string, default: nil)
  attr(:height, :string, default: nil)
  attr(:class, :string, default: nil)

  def skeleton(assigns) do
    ~H"""
    <span :if={@lines <= 1} class={["ds-skeleton", @class]} style={"width:#{@width};height:#{@height}"} aria-hidden="true"></span>
    <div :if={@lines > 1} class={@class} aria-hidden="true">
      <span :for={_ <- 1..@lines} class="ds-skeleton ds-skeleton--text"></span>
    </div>
    """
  end

  # ------------------------------------------------------------- Modal

  @doc """
  Modal / dialog. Hidden until shown with `show_modal/2`; `hide_modal/2` or the
  close affordances hide it. Focus moves into the dialog on show and back to
  the trigger on hide; Escape and scrim-click dismiss unless `blocking`.

      <.modal id="confirm-delete" destructive title="Delete cluster prod-east" on_cancel={JS.push("cancel")}>
        Deletes 14 nodes and their volumes. This cannot be undone.
        <:footer>
          <.button variant={:ghost} phx-click={hide_modal("confirm-delete")}>Cancel</.button>
          <.button variant={:danger} icon="m-delete" phx-click="delete">Delete cluster</.button>
        </:footer>
      </.modal>
      <.button variant={:danger} phx-click={show_modal("confirm-delete")}>Delete cluster prod-east</.button>
  """
  attr(:id, :string, required: true)
  attr(:show, :boolean, default: false, doc: "render open (for server-driven state)")
  attr(:title, :string, required: true)
  attr(:size, :atom, default: :sm, values: [:sm, :md])
  attr(:destructive, :boolean, default: false)
  attr(:blocking, :boolean, default: false)
  attr(:on_cancel, JS, default: %JS{})
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  slot(:footer)

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      class="ds-scrim"
      style={!@show && "display:none"}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
    >
      <div
        id={"#{@id}-dialog"}
        class={["ds-modal", "ds-modal--#{@size}", @destructive && "ds-modal--destructive", @class]}
        role={if @destructive or @blocking, do: "alertdialog", else: "dialog"}
        aria-modal="true"
        aria-labelledby={"#{@id}-title"}
        tabindex="-1"
        phx-window-keydown={!@blocking && JS.exec("data-cancel", to: "##{@id}")}
        phx-key={!@blocking && "escape"}
        phx-click-away={!@blocking && JS.exec("data-cancel", to: "##{@id}")}
      >
        <div class="ds-modal__head">
          <h2 class="ds-modal__title" id={"#{@id}-title"}>{@title}</h2>
          <button :if={!@blocking} type="button" class="ds-modal__x" aria-label="Close" phx-click={JS.exec("data-cancel", to: "##{@id}")}>
            <.mark name="m-close" size={16} />
          </button>
        </div>
        <div class="ds-modal__body">{render_slot(@inner_block)}</div>
        <div :if={@footer != []} class="ds-modal__foot">{render_slot(@footer)}</div>
      </div>
    </div>
    """
  end

  @doc "JS command that opens the modal with the given id and moves focus into it."
  def show_modal(js \\ %JS{}, id) do
    js
    |> JS.show(to: "##{id}", display: "flex")
    |> JS.focus_first(to: "##{id}-dialog")
  end

  @doc "JS command that closes the modal with the given id and returns focus to the trigger."
  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(to: "##{id}")
    |> JS.pop_focus()
  end

  # ------------------------------------------------------------- Toast

  @toast_ms %{critical: 0, high: 12_000, medium: 8_000, low: 5_000, unknown: 5_000, info: 5_000}

  @doc """
  Transient severity notification. `dismiss` is the JS/event for the close
  button. Auto-dismiss is client-side: give the toast an `id` and register the
  `GosUiToast` hook from `priv/static/gos-ui/gos-ui.js`; it honors
  `data-duration` (ms, 0 = persist; critical is always 0). Place inside
  `toast_stack/1`.
  """
  attr(:id, :string, default: nil)
  attr(:severity, :atom, default: :info, values: @steps ++ [:info])
  attr(:title, :string, default: nil)
  attr(:dismiss, :any, default: nil)
  attr(:duration, :integer, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def toast(assigns) do
    sev = Atom.to_string(assigns.severity)

    {c, on, glyph} =
      if assigns.severity == :info,
        do: {"var(--accent)", "var(--on-accent)", "m-info"},
        else:
          {"var(--status-#{sev})", "var(--on-status-#{sev})", @lexicon[assigns.severity].glyph}

    ms =
      if assigns.severity == :critical,
        do: 0,
        else: assigns.duration || @toast_ms[assigns.severity]

    assigns =
      assign(assigns,
        sev: sev,
        style: "--_c:#{c};--_on:#{on}",
        glyph: glyph,
        ms: ms,
        role: if(assigns.severity in [:critical, :high], do: "alert", else: "status"),
        live: if(assigns.severity == :critical, do: "assertive", else: "polite")
      )

    ~H"""
    <div id={@id} class={["ds-toast", @class]} style={@style} data-severity={@sev} data-duration={@ms} phx-hook={@id && "GosUiToast"} role={@role} aria-live={@live} {@rest}>
      <span class="ds-toast__icon"><.mark name={@glyph} size={14} label={@sev} /></span>
      <div class="ds-toast__body">
        <div :if={@title} class="ds-toast__title">{@title}</div>
        {render_slot(@inner_block)}
      </div>
      <button :if={@dismiss} type="button" class="ds-toast__x" aria-label="Dismiss" phx-click={@dismiss}>
        <.mark name="m-close" size={14} />
      </button>
    </div>
    """
  end

  @doc "The fixed corner container for toasts."
  attr(:position, :atom, default: :bottom_right, values: [:bottom_right, :top_right])
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def toast_stack(assigns) do
    assigns =
      assign(assigns, :pos, assigns.position |> Atom.to_string() |> String.replace("_", "-"))

    ~H"""
    <div class={["ds-toasts", "ds-toasts--#{@pos}", @class]} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  @doc """
  Phoenix flash as toasts: `:info` renders as info, `:error` as critical.
  Clicking dismiss clears the flash key server-side.
  """
  attr(:flash, :map, required: true)
  attr(:id, :string, default: "flash-toasts")

  def flash_toasts(assigns) do
    ~H"""
    <.toast_stack id={@id}>
      <.toast
        :for={{kind, sev} <- [info: :info, error: :critical]}
        :if={msg = Phoenix.Flash.get(@flash, kind)}
        id={"#{@id}-#{kind}"}
        severity={sev}
        dismiss={JS.push("lv:clear-flash", value: %{key: kind}) |> JS.hide(to: "##{@id}-#{kind}")}
      >
        {msg}
      </.toast>
    </.toast_stack>
    """
  end

  # ------------------------------------------------- Breadcrumb / pager

  @doc "Location trail: muted ancestor links with chevron separators; the last item is the current page."
  attr(:items, :list, required: true, doc: "maps with :label and optional :navigate or :href")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def breadcrumb(assigns) do
    n = length(assigns.items)

    assigns =
      assign(assigns, :indexed, Enum.with_index(assigns.items, fn it, i -> {it, i == n - 1} end))

    ~H"""
    <nav aria-label="Breadcrumb" class={@class} {@rest}>
      <ol class="ds-crumbs">
        <li :for={{it, last} <- @indexed} class="ds-crumb" aria-current={last && "page"}>
          <span :if={last or (!it[:navigate] and !it[:href])}>{it.label}</span>
          <.link :if={!last and (it[:navigate] || it[:href])} navigate={it[:navigate]} href={it[:href]}>{it.label}</.link>
          <span :if={!last} class="ds-crumb__sep"><.mark name="m-chevron" size={12} /></span>
        </li>
      </ol>
    </nav>
    """
  end

  @doc "Prev/next chevrons + numbered pages with elision; current page = accent tint. `on_change` gets phx-value-page."
  attr(:page, :integer, required: true)
  attr(:total, :integer, required: true)
  attr(:on_change, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def pagination(assigns) do
    assigns = assign(assigns, :pages, page_list(assigns.page, assigns.total))

    ~H"""
    <nav class={["ds-pager", @class]} aria-label="Pagination" {@rest}>
      <button type="button" class="ds-pager__btn ds-pager__btn--prev" aria-label="Previous page" disabled={@page <= 1} phx-click={@on_change} phx-value-page={@page - 1}>
        <.mark name="m-chevron" size={14} />
      </button>
      <%= for p <- @pages do %>
        <span :if={p == :gap} class="ds-pager__gap" aria-hidden="true">…</span>
        <button :if={p != :gap} type="button" class="ds-pager__page" aria-current={p == @page && "page"} aria-label={"Page #{p}"} phx-click={@on_change} phx-value-page={p}>
          {p}
        </button>
      <% end %>
      <button type="button" class="ds-pager__btn ds-pager__btn--next" aria-label="Next page" disabled={@page >= @total} phx-click={@on_change} phx-value-page={@page + 1}>
        <.mark name="m-chevron" size={14} />
      </button>
    </nav>
    """
  end

  @doc false
  def page_list(page, total, around \\ 1) do
    [1, total, page | Enum.flat_map(1..around, &[page - &1, page + &1])]
    |> Enum.filter(&(&1 >= 1 and &1 <= total))
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.reduce([], fn
      p, [prev | _] = acc when is_integer(prev) and p - prev > 1 -> [p, :gap | acc]
      p, acc -> [p | acc]
    end)
    |> Enum.reverse()
  end

  # -------------------------------------------------------------- Menu

  @doc """
  Surface list for popovers and sidebar nav. Items: `%{id, label, icon, hint,
  navigate | href, disabled, submenu}` or `%{separator: true}` / `%{heading: "…"}`.
  Selected = accent tint + left rule. `on_select` gets phx-value-id.
  """
  attr(:items, :list, required: true)
  attr(:selected, :any, default: nil)
  attr(:on_select, :any, default: nil)
  attr(:variant, :atom, default: :popover, values: [:popover, :sidebar])
  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def menu(assigns) do
    ~H"""
    <ul class={["ds-menu", "ds-menu--#{@variant}", @class]} role={if @variant == :sidebar, do: "navigation", else: "menu"} aria-label={@label} {@rest}>
      <%= for it <- @items do %>
        <li :if={it[:separator]} class="ds-menu__sep" role="separator"></li>
        <li :if={it[:heading]} class="ds-menu__heading" role="presentation">{it[:heading]}</li>
        <li :if={!it[:separator] and !it[:heading]} role="none">
          <.link
            :if={it[:navigate] || it[:href]}
            navigate={it[:navigate]}
            href={it[:href]}
            class="ds-menu__item"
            aria-current={@selected == it[:id] && "page"}
            aria-disabled={it[:disabled] && "true"}
          >
            <.mark :if={it[:icon]} name={it[:icon]} size={14} />
            <span class="ds-menu__label">{it[:label]}</span>
            <span :if={it[:hint]} class="ds-menu__hint">{it[:hint]}</span>
            <span :if={it[:submenu]} class="ds-menu__sub"><.mark name="m-chevron" size={12} /></span>
          </.link>
          <button
            :if={!(it[:navigate] || it[:href])}
            type="button"
            class="ds-menu__item"
            role={if @variant == :sidebar, do: nil, else: "menuitem"}
            aria-current={@selected == it[:id] && "true"}
            disabled={it[:disabled]}
            phx-click={@on_select}
            phx-value-id={@on_select && it[:id]}
          >
            <.mark :if={it[:icon]} name={it[:icon]} size={14} />
            <span class="ds-menu__label">{it[:label]}</span>
            <span :if={it[:hint]} class="ds-menu__hint">{it[:hint]}</span>
            <span :if={it[:submenu]} class="ds-menu__sub"><.mark name="m-chevron" size={12} /></span>
          </button>
        </li>
      <% end %>
    </ul>
    """
  end

  # ------------------------------------------------------ Radio / tooltip

  @doc "Radio: checked = accent circle with a filled dot; the dot carries the state."
  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(name value checked disabled form required))

  def radio(assigns) do
    ~H"""
    <label class={["ds-radio", @class]}>
      <input type="radio" class="ds-radio__input" {@rest} />
      <span class="ds-radio__dot" aria-hidden="true"></span>
      <span :if={@label}>{@label}</span>
    </label>
    """
  end

  @doc "Caption bubble on hover and focus with a dotted-underline cue; Escape dismisses until the pointer leaves or focus moves. Never the sole carrier of essential information."
  attr(:text, :string, required: true)
  attr(:id, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def tooltip(assigns) do
    assigns = assign(assigns, :tid, assigns.id || "tip-#{:erlang.phash2(assigns.text)}")

    ~H"""
    <span
      class={["ds-tip", @class]}
      tabindex="0"
      aria-describedby={@tid}
      phx-keydown={JS.set_attribute({"data-dismissed", "true"})}
      phx-key="escape"
      phx-blur={JS.remove_attribute("data-dismissed")}
      onmouseleave="this.removeAttribute('data-dismissed')"
      {@rest}
    >
      {render_slot(@inner_block)}
      <span class="ds-tip__bubble" role="tooltip" id={@tid}>{@text}</span>
    </span>
    """
  end

  # ------------------------------------------------------- Theme switch

  @doc """
  Theme and mode selects. Emits `phx-change` with `theme` and `mode` params;
  apply them with `GosUi.theme_attrs/2` on the root element.
  """
  attr(:theme, :atom, default: :tron)
  attr(:mode, :atom, default: :dark)
  attr(:on_change, :any, required: true, doc: "phx-change event name")
  attr(:class, :string, default: nil)

  def theme_switch(assigns) do
    assigns = assign(assigns, :themes, GosUi.themes())

    ~H"""
    <form class={["ds-theme-switch", @class]} phx-change={@on_change} style="display:inline-flex;gap:var(--space-2);align-items:center">
      <.select name="theme" label="Theme" options={Enum.map(@themes, &{Atom.to_string(&1), Atom.to_string(&1)})} value={@theme} />
      <.select name="mode" label="Mode" options={["dark", "light"]} value={@mode} />
    </form>
    """
  end
end
