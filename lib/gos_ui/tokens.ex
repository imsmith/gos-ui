# GENERATED upstream by tools/elixir.tcl from the edn token files. Do not edit; run make elixir.
defmodule GosUi.Tokens do
  @moduledoc """
  The design-system token backbone as plain Elixir data.

  Generated from `tokens/**/*.edn`, which is the authority for values; the
  manual is the authority for meaning. One function per token file.
  """

  @doc "From `tokens/color/themes.edn`."
  def themes do
    %{
      themes: %{
        tron: %{
          lineage: "Tron — cyan vector grid",
          anchor: "#00E5FF",
          dark: %{
            bg: "#05080a",
            surface: "#0a141a",
            surface_raised: "#0e1c24",
            text: "#cfeff5",
            muted: "#a2bdc3",
            border: "#6d8288",
            accent: "#00E5FF",
            on_accent: "#000000",
            glow: "#00E5FF",
            accent_tint: 0.12
          },
          light: %{
            bg: "#eef7f9",
            surface: "#ffffff",
            surface_raised: "#f4fafb",
            text: "#07232a",
            muted: "#6d7d81",
            border: "#adb6b9",
            accent: "#008c9e",
            on_accent: "#ffffff",
            glow: "#00E5FF",
            accent_tint: 0.10
          }
        },
        matrix: %{
          lineage: "The Matrix — phosphor green",
          anchor: "#03A062",
          dark: %{
            bg: "#020a02",
            surface: "#061206",
            surface_raised: "#0a1c0a",
            text: "#7dffae",
            muted: "#63cb89",
            border: "#438b5c",
            accent: "#03A062",
            on_accent: "#ffffff",
            glow: "#03A062",
            accent_tint: 0.14
          },
          light: %{
            bg: "#f0f7f1",
            surface: "#ffffff",
            surface_raised: "#f4faf5",
            text: "#06250f",
            muted: "#6c7e71",
            border: "#afb9b2",
            accent: "#027a4a",
            on_accent: "#ffffff",
            glow: "#03A062",
            accent_tint: 0.10
          }
        },
        compaq: %{
          lineage: "Compaq Portable III — amber gas-plasma",
          anchor: "#FF8A00",
          dark: %{
            bg: "#160f04",
            surface: "#20160a",
            surface_raised: "#2a1e0d",
            text: "#ffd9a0",
            muted: "#d5b484",
            border: "#947b58",
            accent: "#FF8A00",
            on_accent: "#000000",
            glow: "#FF8A00",
            accent_tint: 0.13
          },
          light: %{
            bg: "#fbf4ea",
            surface: "#ffffff",
            surface_raised: "#faf5ec",
            text: "#2a1a06",
            muted: "#837a6f",
            border: "#bbb6af",
            accent: "#c96a00",
            on_accent: "#ffffff",
            glow: "#FF8A00",
            accent_tint: 0.10
          }
        }
      }
    }
  end

  @doc "From `tokens/color/spectrum.edn`."
  def spectrum do
    %{
      stops: [
        %{
          name: :plumb,
          hex12: "#817",
          hex24: "#881177",
          pole: :warm,
          index: 5
        },
        %{
          name: :red,
          hex12: "#a35",
          hex24: "#aa3355",
          pole: :warm,
          index: 4
        },
        %{
          name: :pink,
          hex12: "#c66",
          hex24: "#cc6666",
          pole: :warm,
          index: 3
        },
        %{
          name: :orange,
          hex12: "#e95",
          hex24: "#ee9955",
          pole: :warm,
          index: 2
        },
        %{
          name: :yellow,
          hex12: "#ed0",
          hex24: "#eedd00",
          pole: :warm,
          index: 1
        },
        %{
          name: :green,
          hex12: "#9d5",
          hex24: "#99dd55",
          pole: :center,
          index: 0
        },
        %{
          name: :seafoam,
          hex12: "#4d8",
          hex24: "#44dd88",
          pole: :cool,
          index: -1
        },
        %{
          name: :turquoise,
          hex12: "#2cb",
          hex24: "#22ccbb",
          pole: :cool,
          index: -2
        },
        %{
          name: :teal,
          hex12: "#0bc",
          hex24: "#00bbcc",
          pole: :cool,
          index: -3
        },
        %{
          name: :blue,
          hex12: "#09c",
          hex24: "#0099cc",
          pole: :cool,
          index: -4
        },
        %{
          name: :indigo,
          hex12: "#36b",
          hex24: "#3366bb",
          pole: :cool,
          index: -5
        },
        %{
          name: :purple,
          hex12: "#639",
          hex24: "#663399",
          pole: :cool,
          index: -6
        }
      ]
    }
  end

  @doc "From `tokens/color/status.edn`."
  def status do
    %{
      ramp: [
        %{
          step: :critical,
          hue_source: :red,
          hex24: "#ff6472",
          on_status: "#ffffff"
        },
        %{
          step: :high,
          hue_source: :orange,
          hex24: "#ff7a00",
          on_status: "#ffffff"
        },
        %{
          step: :medium,
          hue_source: :yellow,
          hex24: "#ffd400",
          on_status: "#000000"
        },
        %{
          step: :low,
          hue_source: :green,
          hex24: "#2fd44e",
          on_status: "#000000"
        },
        %{
          step: :unknown,
          hue_source: nil,
          hex24: "#9ca2ac",
          on_status: "#ffffff"
        }
      ],
      treatment: %{
        variants: [:fill, :outline],
        light_surfaces: [:fill],
        dark_surfaces: [:fill, :outline]
      },
      oasis_cap: %{
        severity: %{
          standard: "OASIS CAP 1.2",
          alarm_valenced: true,
          map: %{
            "Extreme" => :critical,
            "Severe" => :high,
            "Moderate" => :medium,
            "Minor" => :low,
            "Unknown" => :unknown
          }
        },
        urgency: %{
          standard: "OASIS CAP 1.2",
          alarm_valenced: true,
          map: %{
            "Immediate" => :critical,
            "Expected" => :high,
            "Future" => :medium,
            "Past" => :low,
            "Unknown" => :unknown
          }
        },
        certainty: %{
          standard: "OASIS CAP 1.2",
          alarm_valenced: false,
          note: "Ordinal only. Encode by intensity, not alarm hue, unless an
                     ordered ramp is explicitly requested and labeled.",
          order: ["Observed", "Likely", "Possible", "Unlikely", "Unknown"]
        }
      }
    }
  end

  @doc "From `tokens/color/opinion.edn`."
  def opinion do
    %{
      map: [
        %{
          value: "strongly-disagree",
          stop: :red,
          hex24: "#aa3355",
          index: 4
        },
        %{
          value: "disagree",
          stop: :orange,
          hex24: "#ee9955",
          index: 2
        },
        %{
          value: "neutral",
          stop: :green,
          hex24: "#99dd55",
          index: 0
        },
        %{
          value: "agree",
          stop: :turquoise,
          hex24: "#22ccbb",
          index: -2
        },
        %{
          value: "strongly-agree",
          stop: :blue,
          hex24: "#0099cc",
          index: -4
        }
      ]
    }
  end

  @doc "From `tokens/color/markings.edn`."
  def markings do
    %{
      markings: [
        %{
          name: "TLP:RED",
          hex24: "#FF2B2B"
        },
        %{
          name: "TLP:AMBER",
          hex24: "#FFC000"
        },
        %{
          name: "TLP:AMBER+STRICT",
          hex24: "#FFC000"
        },
        %{
          name: "TLP:GREEN",
          hex24: "#33FF00"
        },
        %{
          name: "TLP:CLEAR",
          hex24: "#FFFFFF"
        }
      ]
    }
  end

  @doc "From `tokens/typography.edn`."
  def typography do
    %{
      families: %{
        mono: %{
          role: "voice — headings, labels, data, code, UI",
          primary: "MartianMono Nerd Font",
          terminal: "MartianMono Nerd Font Mono",
          license: "SIL OFL 1.1",
          source: "github.com/ryanoasis/nerd-fonts (patched Evil Martians Martian Mono)",
          web_fallback:
            "Martian Mono (plain, Google Fonts) when the Nerd Font is not self-hosted",
          stack: [
            "MartianMono Nerd Font",
            "Martian Mono",
            "ui-monospace",
            "SF Mono",
            "Menlo",
            "Consolas",
            "monospace"
          ]
        },
        prose: %{
          role: "long-form running text ONLY",
          primary: "Martian Grotesk",
          license: "SIL OFL 1.1",
          note: "proportional sibling of Martian Mono; no Nerd Font patch (mono-only feature)",
          stack: ["Martian Grotesk", "Space Grotesk", "ui-sans-serif", "system-ui", "sans-serif"]
        }
      },
      scale: [
        %{
          token: :display,
          px: 40,
          rem: 2.5,
          role: "hero / display"
        },
        %{
          token: :h1,
          px: 32,
          rem: 2.0,
          role: "page title"
        },
        %{
          token: :h2,
          px: 24,
          rem: 1.5,
          role: "section heading"
        },
        %{
          token: :h3,
          px: 20,
          rem: 1.25,
          role: "subsection heading"
        },
        %{
          token: :lead,
          px: 18,
          rem: 1.125,
          role: "lead paragraph"
        },
        %{
          token: :body,
          px: 16,
          rem: 1.0,
          role: "base running text"
        },
        %{
          token: :small,
          px: 14,
          rem: 0.875,
          role: "secondary text"
        },
        %{
          token: :caption,
          px: 12,
          rem: 0.75,
          role: "captions / labels"
        },
        %{
          token: :micro,
          px: 11,
          rem: 0.6875,
          role: "dense data / fine print"
        }
      ],
      weights: %{
        regular: 400,
        medium: 500,
        bold: 700
      },
      line_height: %{
        tight: 1.15,
        snug: 1.4,
        normal: 1.6
      },
      tracking: %{
        label: "0.08em",
        tight: "-0.01em"
      },
      measure: %{
        prose: "60-75ch",
        data: "unwrapped"
      },
      terminal: %{
        font: "MartianMono Nerd Font Mono",
        hierarchy: [
          "UPPERCASE",
          "weight (bold / dim)",
          "reverse video",
          "letter-spacing",
          "rule lines",
          "Nerd Font icon glyphs"
        ]
      }
    }
  end

  @doc "From `tokens/space.edn`."
  def space do
    %{
      scale: [
        %{
          token: :space_half,
          px: 4,
          rem: 0.25,
          role: "half-step, tight adjustments"
        },
        %{
          token: :space_1,
          px: 8,
          rem: 0.5,
          role: "base unit"
        },
        %{
          token: :space_2,
          px: 16,
          rem: 1.0,
          role: "default gap"
        },
        %{
          token: :space_3,
          px: 24,
          rem: 1.5,
          role: "gutter, section gap"
        },
        %{
          token: :space_4,
          px: 32,
          rem: 2.0
        },
        %{
          token: :space_5,
          px: 48,
          rem: 3.0
        },
        %{
          token: :space_6,
          px: 64,
          rem: 4.0
        },
        %{
          token: :space_7,
          px: 96,
          rem: 6.0
        },
        %{
          token: :space_8,
          px: 128,
          rem: 8.0,
          role: "major section / page rhythm"
        }
      ],
      density: %{
        comfortable: %{
          token: :space_2,
          px: 16,
          role: "default reading density"
        },
        compact: %{
          token: :space_1,
          px: 8,
          role: "dashboards, denser UI"
        },
        dense: %{
          token: :space_half,
          px: 4,
          role: "telemetry / log tables"
        }
      },
      grid: %{
        columns: 12,
        gutter: %{
          token: :space_3,
          px: 24
        },
        margin: %{
          token: :space_3,
          px: 24
        },
        breakpoints: [
          %{
            name: :xs,
            min: 0
          },
          %{
            name: :sm,
            min: 640
          },
          %{
            name: :md,
            min: 768
          },
          %{
            name: :lg,
            min: 1024
          },
          %{
            name: :xl,
            min: 1280
          },
          %{
            name: :"2xl",
            min: 1536
          }
        ]
      },
      border: %{
        width: "1px"
      },
      radius: [
        %{
          token: :radius_none,
          px: 0,
          role: "tables, rules, terminal-like surfaces"
        },
        %{
          token: :radius_sm,
          px: 2,
          role: "badges, tags, inputs"
        },
        %{
          token: :radius_md,
          px: 4,
          role: "default control radius (buttons, selects)"
        },
        %{
          token: :radius_lg,
          px: 6,
          role: "cards, panels, overlays"
        }
      ],
      measure: %{
        prose: "72ch",
        range: "60-75ch",
        unit: "ch"
      },
      terminal: %{
        reference_cols: 80,
        wide_cols: 120,
        unit: "cells — 1 column ≈ 1ch horizontal, 1 row vertical",
        note: "spacing is integer cells; gaps in columns (ch), vertical rhythm in rows"
      }
    }
  end

  @doc "From `tokens/motion.edn`."
  def motion do
    %{
      duration: [
        %{
          token: :instant,
          ms: 0,
          role: "state with no travel (focus ring)"
        },
        %{
          token: :fast,
          ms: 120,
          role: "hover, small toggles"
        },
        %{
          token: :moderate,
          ms: 200,
          role: "most transitions (menu, expand)"
        },
        %{
          token: :deliberate,
          ms: 320,
          role: "larger entrances (modal, panel)"
        }
      ],
      easing: %{
        standard: "cubic-bezier(0.2, 0, 0, 1)",
        enter: "cubic-bezier(0, 0, 0, 1)",
        exit: "cubic-bezier(0.4, 0, 1, 1)",
        linear: "linear"
      },
      pulse: %{
        use: "critical / live elements only",
        property: "opacity (and glow)",
        period_ms: 1500,
        reduced_motion: "static — no pulse"
      }
    }
  end

  @doc "From `tokens/material.edn`."
  def material do
    %{
      glow: %{
        ambient: %{
          text: [
            %{
              x: 0,
              y: 0,
              blur: 6,
              alpha: 0.40
            }
          ],
          box: [
            %{
              x: 0,
              y: 0,
              blur: 8,
              alpha: 0.33
            }
          ]
        },
        active: %{
          text: [
            %{
              x: 0,
              y: 0,
              blur: 10,
              alpha: 0.80
            }
          ],
          box: [
            %{
              x: 0,
              y: 0,
              blur: 16,
              alpha: 0.67
            },
            %{
              x: 0,
              y: 0,
              blur: 4,
              alpha: 1.00
            }
          ]
        }
      }
    }
  end

  @doc "From `tokens/marks.edn`."
  def marks do
    %{
      status: [
        %{
          id: "m-critical",
          step: :critical,
          shape: :octagon,
          symbol: :x,
          unicode: "✖",
          ascii: "[X]",
          nerd: "f05c",
          nerd_name: "nf-fa-times_circle"
        },
        %{
          id: "m-high",
          step: :high,
          shape: :triangle,
          symbol: :bang,
          unicode: "▲",
          ascii: "[!]",
          nerd: "f071",
          nerd_name: "nf-fa-warning"
        },
        %{
          id: "m-medium",
          step: :medium,
          shape: :diamond,
          symbol: :bang,
          unicode: "◆",
          ascii: "[*]",
          nerd: "f06a",
          nerd_name: "nf-fa-exclamation_circle"
        },
        %{
          id: "m-low",
          step: :low,
          shape: :circle,
          symbol: :check,
          unicode: "●",
          ascii: "[+]",
          nerd: "f058",
          nerd_name: "nf-fa-check_circle"
        },
        %{
          id: "m-unknown",
          step: :unknown,
          shape: :square,
          symbol: :query,
          unicode: "□",
          ascii: "[?]",
          nerd: "f059",
          nerd_name: "nf-fa-question_circle"
        }
      ],
      diverging: [
        %{
          id: "m-warm",
          sign: :positive,
          pole: :warm,
          unicode: "⌃",
          ascii: "^",
          nerd: "f106",
          nerd_name: "nf-fa-angle_up"
        },
        %{
          id: "m-neutral",
          sign: :zero,
          pole: :center,
          unicode: "–",
          ascii: "-",
          nerd: "f068",
          nerd_name: "nf-fa-minus"
        },
        %{
          id: "m-cool",
          sign: :negative,
          pole: :cool,
          unicode: "⌄",
          ascii: "v",
          nerd: "f107",
          nerd_name: "nf-fa-angle_down"
        }
      ],
      ui: [
        %{
          id: "m-close",
          group: :nav,
          unicode: "✕",
          ascii: "x",
          nerd: "f00d",
          nerd_name: "nf-fa-times"
        },
        %{
          id: "m-menu",
          group: :nav,
          unicode: "≡",
          ascii: "=",
          nerd: "f0c9",
          nerd_name: "nf-fa-bars"
        },
        %{
          id: "m-chevron",
          group: :nav,
          unicode: "›",
          ascii: ">",
          nerd: "f054",
          nerd_name: "nf-fa-chevron_right",
          note: "rotate 90/180/270 for up/left/down"
        },
        %{
          id: "m-more",
          group: :nav,
          unicode: "⋯",
          ascii: "...",
          nerd: "f141",
          nerd_name: "nf-fa-ellipsis_h"
        },
        %{
          id: "m-search",
          group: :action,
          unicode: "⌕",
          ascii: nil,
          nerd: "f002",
          nerd_name: "nf-fa-search"
        },
        %{
          id: "m-add",
          group: :action,
          unicode: "+",
          ascii: "+",
          nerd: "f067",
          nerd_name: "nf-fa-plus"
        },
        %{
          id: "m-remove",
          group: :action,
          unicode: "−",
          ascii: "-",
          nerd: "f068",
          nerd_name: "nf-fa-minus"
        },
        %{
          id: "m-edit",
          group: :action,
          unicode: "✎",
          ascii: nil,
          nerd: "f040",
          nerd_name: "nf-fa-pencil"
        },
        %{
          id: "m-delete",
          group: :action,
          unicode: nil,
          ascii: "del",
          nerd: "f1f8",
          nerd_name: "nf-fa-trash"
        },
        %{
          id: "m-refresh",
          group: :action,
          unicode: "↻",
          ascii: nil,
          nerd: "f021",
          nerd_name: "nf-fa-refresh"
        },
        %{
          id: "m-filter",
          group: :action,
          unicode: "▽",
          ascii: nil,
          nerd: "f0b0",
          nerd_name: "nf-fa-filter"
        },
        %{
          id: "m-download",
          group: :action,
          unicode: "↓",
          ascii: "v",
          nerd: "f019",
          nerd_name: "nf-fa-download"
        },
        %{
          id: "m-upload",
          group: :action,
          unicode: "↑",
          ascii: "^",
          nerd: "f093",
          nerd_name: "nf-fa-upload"
        },
        %{
          id: "m-settings",
          group: :object,
          unicode: "⚙",
          ascii: nil,
          nerd: "f013",
          nerd_name: "nf-fa-cog"
        },
        %{
          id: "m-info",
          group: :object,
          unicode: "ⓘ",
          ascii: "i",
          nerd: "f05a",
          nerd_name: "nf-fa-info_circle"
        },
        %{
          id: "m-help",
          group: :object,
          unicode: "?",
          ascii: "?",
          nerd: "f128",
          nerd_name: "nf-fa-question"
        },
        %{
          id: "m-user",
          group: :object,
          unicode: nil,
          ascii: nil,
          nerd: "f007",
          nerd_name: "nf-fa-user"
        },
        %{
          id: "m-lock",
          group: :object,
          unicode: nil,
          ascii: nil,
          nerd: "f023",
          nerd_name: "nf-fa-lock"
        },
        %{
          id: "m-bell",
          group: :object,
          unicode: nil,
          ascii: nil,
          nerd: "f0f3",
          nerd_name: "nf-fa-bell"
        }
      ]
    }
  end

  @doc "From `tokens/voice.edn`."
  def voice do
    %{
      principles: [
        "direct",
        "precise",
        "no filler",
        "name the problem",
        "state the action",
        "no fake reassurance"
      ],
      status_lexicon: [
        %{
          step: :critical,
          oasis: "Extreme",
          display: "DOWN",
          glyph: "m-critical"
        },
        %{
          step: :high,
          oasis: "Severe",
          display: "ALERT",
          glyph: "m-high"
        },
        %{
          step: :medium,
          oasis: "Moderate",
          display: "WARN",
          glyph: "m-medium"
        },
        %{
          step: :low,
          oasis: "Minor",
          display: "OK",
          glyph: "m-low"
        },
        %{
          step: :unknown,
          oasis: "Unknown",
          display: "UNK",
          glyph: "m-unknown"
        }
      ],
      message_shape: ["what happened", "why (if known)", "what to do"]
    }
  end

  @doc "From `tokens/components.edn`."
  def components do
    %{
      state_matrix: %{
        default: %{
          bg: :surface,
          text: :text,
          border: :border,
          glow: nil
        },
        hover: %{
          emphasis: "outlined: border→accent; filled: brighten accent",
          glow: :ambient
        },
        focus: %{
          outline: :text,
          outline_offset: "space-half (4px)",
          glow: :active,
          note: "outline is the signal; glow is reinforcement (Accessibility §5)"
        },
        active: %{
          fill: :accent,
          on_fill: :on_accent,
          shift: "pressed/inset"
        },
        disabled: %{
          text: :muted,
          opacity: 0.5,
          glow: nil,
          interactive: false
        },
        loading: %{
          indicator: "m-refresh (animated)",
          aria_busy: true,
          content: :hidden
        },
        error: %{
          border: :"status/critical",
          text: :"status/critical",
          message: true,
          glyph: "m-critical",
          note: "color + glyph + text, never color alone"
        },
        selected: %{
          tint: "accent @ low alpha",
          rule: "accent left/underline",
          glow: nil
        },
        read_only: %{
          border: :none,
          bg: :surface,
          editable: false,
          selectable: true
        }
      },
      gauge: %{
        diverging: %{
          color: :"color/spectrum",
          center: :green,
          mark: [:m_warm, :m_neutral, :m_cool],
          label: "signed value, always shown",
          use: "temperature, error-vs-baseline, STIX opinion"
        },
        sequential: %{
          fill: :accent,
          threshold: "alert ramp: warn→medium, crit→critical",
          thresholds: "per-instance config (e.g. warn 70%, crit 90%), not a token",
          label: "value + threshold word (Voice display synonym)",
          use: "CPU, disk, memory, throughput, quota"
        },
        forms: [:linear, :radial],
        no_data: %{
          color: :muted,
          glyph: "m-unknown",
          word: "UNK"
        }
      },
      chart: %{
        forms: [:sparkline, :line_area, :bar],
        diverging: %{
          color: :"color/spectrum",
          baseline: "dashed nominal (green/0)"
        },
        threshold: %{
          line: :accent,
          crossing: "alert ramp color + word"
        },
        plain: %{
          line: :text
        },
        many: %{
          strategy: :small_multiples,
          overlay: "≤2-3 series: mono-ramp (accent solid, muted dashed) + direct end-labels",
          never: "categorical color palette — spectrum is diverging, not categorical"
        },
        no_data: %{
          color: :muted,
          glyph: "m-unknown",
          word: "UNK"
        },
        terminal: "block/braille sparkline + value + status word"
      },
      overlay: %{
        modal: %{
          focus_trap: true,
          return_focus: true,
          dismiss: [:esc, :scrim],
          aria: "aria-modal, labelled by title",
          motion: [:deliberate, :enter, :exit]
        },
        toast: %{
          auto_dismiss: "timer by severity; critical persists",
          aria_live: "polite; assertive for critical",
          affordance: "m-bell"
        },
        tooltip: %{
          trigger: [:hover, :focus],
          dismiss: [:blur, :esc],
          rule: "never the sole carrier of essential info"
        },
        menu: %{
          keyboard: true,
          selected: "accent tint + rule",
          dismiss: [:select, :blur, :esc]
        }
      },
      destructive: %{
        color: :"status/critical",
        label: "verb naming the act (e.g. DELETE)",
        copy: "name the target; state irreversibility (Voice §3)",
        cancel: :ghost
      }
    }
  end
end
