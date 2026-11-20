# ISSUES

Running list of friction, footguns, and small fixes surfaced by gos-ui consumers. Newest at the top. Mark resolved with `~~strikethrough~~` and a one-line note.

---

## 2026-10-14 — follow-ups from agento's design-system migration

Surfaced while re-skinning agento to imsmith/design-system through gos-ui. Each is worked around in agento today.

### 1. ~~`theme_switch` should default `phx-auto-recover="ignore"` for a non-push `on_change`~~

Resolved 2026-11-20: `theme_switch` emits `phx-auto-recover="ignore"` when `on_change` is a `%JS{}` with no `push` op; a string event or `JS.push` leaves recovery on; an explicit `phx-auto-recover` attr wins.

The form has an id and a `phx-change`, so LiveView treats it as a form-recovery candidate on every rejoin. With `on_change={JS.dispatch(...)}` there is no push op, the recovery callback never fires, and the join never completes: after any reconnect the page is dead until a hard reload. agento passes `phx-auto-recover="ignore"` in `layouts.ex`; gos-ui should do it by default when `on_change` is not a push.

### 2. ~~`table` should emit `row_id` as a DOM id~~

Resolved 2026-11-20: give the table an `id`; each `<tr>` gets `id="<table id>-<row_id>"` (`<.table id="performer" ...>` → `#performer-*`). No table id, no row ids, so bare numeric ids never collide across tables.

`row_id` only feeds `phx-value-id` (`lib/gos_ui/components.ex:710`). Tests that select rows by id (`#performer-*`, `#policy-*`) forced agento to hand-write every table with `ds-table__*` classes.

### 3. ~~`select`/`input` derive `id` from `label`~~

Resolved 2026-11-20 for the reported collision: `theme_switch` now namespaces its selects as `<form id>-theme` / `<form id>-mode`, so the shell no longer squats on `ds-mode`. The label-derived default for standalone `input`/`select` is unchanged: a page-unique default that is also stable across renders needs caller context, and an unstable id would break LiveView DOM patching and focus. Pass `id` when two fields share a label.

Two controls labelled the same on one page collide (agento's `Mode` collided with the shell's theme-mode select). An explicit `id` attr exists; a page-unique default would be safer.
