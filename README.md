# gos-ui

GRID·OPS design-system components for Phoenix LiveView and Livebook. A BEAM
consumer of [imsmith/design-system](https://github.com/imsmith/design-system):
that repo's manual is the authority for meaning and its `edn` tokens for
values. This library vendors the generated serializations and adds the Elixir
side.

## What is here

- `priv/static/gos-ui/` — `styles.css`, the generated token CSS, the
  self-hosted Martian fonts, and the mark sprite. Copied verbatim by
  `make sync`; never edited here.
- `GosUi.Tokens` — the token backbone as plain Elixir data (generated upstream,
  renamed on sync).
- `GosUi.Components` — the full suite as HEEx function components: `sprite`,
  `mark`, `status_badge`, `alert`, `button`, `card`, `tag`, `diverging_meter`,
  `sequential_meter`, `sparkline`, `heatmap`, `input`, `select`, `checkbox`,
  `toggle`, `tabs`. Class names mirror the reference React components, so the
  one shared `components.css` carries every rule. Interactive pieces (tabs,
  heatmap cells, dismiss and remove buttons) take a `phx-click` event name and
  send `phx-value-id`; state (`active`, `checked`, `value`) is server-driven.
- `GosUi.Livebook` — data color as data (`scale/1`, `domain/1` for VegaLite),
  `status_text/2` for logs, and a self-contained fill-treatment badge.

## Phoenix

Serve the static root and link the stylesheet from the root layout:

```elixir
# endpoint.ex
plug Plug.Static, at: "/gos-ui", from: {:gos_ui, "priv/static/gos-ui"}, gzip: false
```

```heex
<link rel="stylesheet" href="/gos-ui/styles.css" />
<body data-theme="tron">
  <.sprite />
  ...
```

Then in a view:

```elixir
use GosUi

~H"""
<.status_badge step={:critical} pulse />
<.alert severity={:high} title="Replica lag 42 s." dismiss="dismiss-lag">
  Primary under write burst. Check db-03 before failover.
</.alert>
<.button variant={:danger} phx-click="delete">Delete cluster prod-east</.button>
"""
```

Theme and mode are attributes on an ancestor: `data-theme="tron|matrix|compaq"`
and `data-mode="light"` (dark is the default). The status treatment rule is
enforced by the stylesheet: every badge variant renders as fill on light
surfaces, and `critical` is always fill.

## Livebook

```elixir
Mix.install([{:gos_ui, github: "imsmith/gos-ui"}, :kino, :vega_lite])

GosUi.Livebook.status_badge(:medium)             # Kino.HTML output
GosUi.Livebook.status_text(:critical, ascii: true) # "[X] DOWN"

VegaLite.new()
|> VegaLite.encode_field(:color, "severity",
  type: :nominal,
  scale: [domain: GosUi.Livebook.domain(:status), range: GosUi.Livebook.scale(:status)]
)
```

## Keeping in sync

```bash
make sync DESIGN_SYSTEM=../design-system   # vendor from a local checkout; records the commit
make check                                 # format, compile --warnings-as-errors, test
```

`priv/design-system.rev` holds the upstream commit the vendored files came from.

## License

AGPL-3.0-or-later. The vendored manual-derived assets (tokens, marks, fonts)
keep their upstream licenses: CC BY-NC-SA 4.0 for tokens and marks, SIL OFL 1.1
for the Martian fonts.
