defmodule GosUiTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest, only: [rendered_to_string: 1]
  import GosUi.Components

  test "tokens come from the vendored module" do
    assert GosUi.Tokens.status().treatment.light_surfaces == [:fill]
    assert GosUi.Tokens.themes().themes.tron.dark.accent == "#00E5FF"
  end

  test "status badge derives glyph and word from the step" do
    assigns = %{}
    html = rendered_to_string(~H|<.status_badge step={:critical} pulse />|)
    assert html =~ ~s(data-step="critical")
    assert html =~ "ds-pulse"
    assert html =~ ~s(href="#m-critical")
    assert html =~ ">DOWN<"
    assert html =~ "--on-status-critical"
  end

  test "alert uses role=alert for critical/high and a fill chip glyph" do
    assigns = %{}

    html =
      rendered_to_string(
        ~H|<.alert severity={:high} title="Replica lag 42 s.">Check db-03.</.alert>|
      )

    assert html =~ ~s(role="alert")
    assert html =~ "ds-alert__icon"
    assert html =~ "--on-status-high"
    assert html =~ "Check db-03."

    info = rendered_to_string(~H|<.alert title="Maintenance 02:00 UTC." />|)
    assert info =~ ~s(role="status")
    assert info =~ "--on-accent"
  end

  test "button variants and loading state" do
    assigns = %{}
    html = rendered_to_string(~H|<.button variant={:danger} loading>Delete sector 12</.button>|)
    assert html =~ "ds-btn--danger"
    assert html =~ ~s(data-loading="true")
    assert html =~ ~s(aria-busy="true")
    assert html =~ "m-refresh"
  end

  test "sprite inlines the mark symbols hidden" do
    assigns = %{}
    html = rendered_to_string(~H|<.sprite />|)
    assert html =~ ~s(<svg style="display:none")
    assert html =~ ~s(id="m-unknown")
  end

  test "livebook helpers hand out data color as data" do
    assert length(GosUi.Livebook.scale(:spectrum)) == 12
    assert GosUi.Livebook.scale(:status) |> hd() == "#ff6472"
    assert GosUi.Livebook.status_text(:medium) == "◆ WARN"
    assert GosUi.Livebook.status_text(:medium, ascii: true) == "[*] WARN"
    assert GosUi.Livebook.status_badge_html(:low) =~ "background:#2fd44e;color:#000000"
  end

  test "tag with remove" do
    assigns = %{}
    html = rendered_to_string(~H|<.tag icon="m-lock" remove="rm">TLP:AMBER</.tag>|)
    assert html =~ "ds-tag"
    assert html =~ ~s(phx-click="rm")
  end

  test "diverging meter colors by spectrum stop and always shows the signed value" do
    assigns = %{}
    html = rendered_to_string(~H|<.diverging_meter value={2.0} label="drift" unit="σ" />|)
    assert html =~ "--spectrum-orange"
    assert html =~ "m-warm"
    assert html =~ "+2.0σ"
    assert html =~ ~s(left:50%)

    neg = rendered_to_string(~H|<.diverging_meter value={-3} />|)
    assert neg =~ "--spectrum-teal"
    assert neg =~ "−3"
  end

  test "sequential meter adopts the alert ramp and word on thresholds" do
    assigns = %{}

    html =
      rendered_to_string(~H|<.sequential_meter value={92} warn={70} crit={90} label="cpu" />|)

    assert html =~ "--status-critical"
    assert html =~ "CRIT"
    assert html =~ "ds-meter__tick--warn"
    ok = rendered_to_string(~H|<.sequential_meter value={12} warn={70} />|)
    assert ok =~ "--accent"
    refute ok =~ "WARN"
  end

  test "sparkline draws a path and threshold lines" do
    assigns = %{}
    html = rendered_to_string(~H|<.sparkline data={[1, 3, 2, 5]} mode={:threshold} warn={4} />|)
    assert html =~ ~s(d="M2.0,22.0 L32.7,12.0)
    assert html =~ "stroke-dasharray"
    assert html =~ "WARN"
    assert rendered_to_string(~H|<.sparkline data={[]} />|) =~ "ds-spark"
  end

  test "heatmap cells carry titles, critical glyphs, and the legend" do
    assigns = %{
      cells: [
        %{id: "a", value: 0},
        %{id: "b", value: 4.4, label: "node-13"},
        %{id: "c", value: -2}
      ]
    }

    html = rendered_to_string(~H|<.heatmap cells={@cells} columns={3} select="pick" />|)
    assert html =~ ~s(title="node-13: +4.4")
    assert html =~ ~s(phx-value-id="b")
    assert html =~ "m-critical"
    assert html =~ "ds-heat__legend"
    assert html =~ "repeat(3, minmax(0,1fr))"
  end

  test "form controls" do
    assigns = %{}

    input =
      rendered_to_string(
        ~H|<.input label="Port" name="port" value="99999" error="Port out of range. Use 1–65535." />|
      )

    assert input =~ ~s(id="ds-port")
    assert input =~ "ds-field--error"
    assert input =~ ~s(aria-invalid="true")
    assert input =~ "m-critical"

    sel =
      rendered_to_string(
        ~H|<.select label="Sector" name="s" options={["12", {"Thirteen", "13"}]} value="13" />|
      )

    assert sel =~ ~s(<option value="13" selected>Thirteen</option>)
    assert sel =~ "m-chevron"

    assert rendered_to_string(~H|<.checkbox label="Ack" name="ack" checked />|) =~
             "ds-check__mark"

    tog = rendered_to_string(~H|<.toggle label="Live" checked show_state />|)
    assert tog =~ ~s(role="switch")
    assert tog =~ ">ON<"
  end

  test "tabs mark the active id and wire selection" do
    assigns = %{
      tabs: [
        %{id: "grid", label: "Grid", icon: "m-menu"},
        %{id: "alerts", label: "Alerts", count: 3}
      ]
    }

    html = rendered_to_string(~H|<.tabs tabs={@tabs} active="alerts" select="tab" />|)
    assert html =~ ~s(aria-selected="true")
    assert html =~ ~s(phx-value-id="alerts")
    assert html =~ "ds-tab__count"
  end

  test "table: slots, sort state, numeric alignment, selection" do
    assigns = %{
      rows: [%{id: "n1", cpu: 42}, %{id: "n2", cpu: 97}],
      sort: %{key: "cpu", dir: :descending}
    }

    html =
      rendered_to_string(~H"""
      <.table rows={@rows} selected="n2" on_select="pick" sort={@sort} on_sort="sort" density={:compact}>
        <:col :let={r} key="id" label="Node" sortable>{r.id}</:col>
        <:col :let={r} key="cpu" label="CPU %" num sortable>{r.cpu}</:col>
      </.table>
      """)

    assert html =~ "ds-table--compact"
    assert html =~ ~s(aria-sort="descending")
    assert html =~ ~s(aria-sort="none")
    assert html =~ "ds-table__td--num"
    assert html =~ ~s(aria-selected="true")
    assert html =~ ~s(phx-value-id="n2")
    assert html =~ ~s(phx-value-key="cpu")
  end

  test "state panel triad and skeleton" do
    assigns = %{}

    err =
      rendered_to_string(
        ~H|<.state_panel mode={:error} title="Telemetry unavailable"><:action><.button>Retry</.button></:action>db-03 timed out.</.state_panel>|
      )

    assert err =~ ~s(role="alert")
    assert err =~ "m-critical"
    assert err =~ "ds-state__action"
    load = rendered_to_string(~H|<.state_panel mode={:loading} title="Loading" />|)
    assert load =~ ~s(aria-busy="true")

    assert rendered_to_string(~H|<.skeleton lines={4} />|)
           |> String.split("ds-skeleton--text")
           |> length() == 5
  end

  test "modal markup and JS commands" do
    assigns = %{}

    html =
      rendered_to_string(
        ~H|<.modal id="m" destructive title="Delete cluster prod-east"><:footer><.button variant={:danger}>Delete cluster</.button></:footer>Cannot be undone.</.modal>|
      )

    assert html =~ ~s(role="alertdialog")
    assert html =~ "ds-modal--destructive"
    assert html =~ ~s(phx-key="escape")
    assert html =~ "display:none"
    assert inspect(show_modal("m")) =~ "focus_first"
    assert inspect(hide_modal("m")) =~ "pop_focus"
    blocking = rendered_to_string(~H|<.modal id="b" blocking title="Working">Hold.</.modal>|)
    refute blocking =~ "ds-modal__x"
  end

  test "toasts: critical persists and is assertive; flash maps to toasts" do
    assigns = %{flash: %{"error" => "Uplink down.", "info" => "Saved."}}

    crit =
      rendered_to_string(
        ~H|<.toast_stack><.toast severity={:critical} title="Uplink down" dismiss="ack">Acknowledge.</.toast></.toast_stack>|
      )

    assert crit =~ ~s(data-duration="0")
    assert crit =~ ~s(aria-live="assertive")
    assert crit =~ "ds-toasts--bottom-right"
    low = rendered_to_string(~H|<.toast severity={:low} title="ok" />|)
    assert low =~ ~s(data-duration="5000")
    flash = rendered_to_string(~H|<.flash_toasts flash={@flash} />|)
    assert flash =~ ~s(data-severity="critical")
    assert flash =~ "Saved."
    assert flash =~ "lv:clear-flash"
  end

  test "breadcrumb, pagination, menu" do
    assigns = %{
      items: [
        %{label: "Grid", navigate: "/"},
        %{label: "Sector 12", href: "/s/12"},
        %{label: "node-13"}
      ]
    }

    crumbs = rendered_to_string(~H|<.breadcrumb items={@items} />|)
    assert crumbs =~ ~s(aria-current="page")
    assert crumbs =~ ~s(href="/s/12")
    assert crumbs =~ "ds-crumb__sep"

    assert GosUi.Components.page_list(4, 9) == [1, :gap, 3, 4, 5, :gap, 9]
    assert GosUi.Components.page_list(1, 3) == [1, 2, 3]
    pager = rendered_to_string(~H|<.pagination page={4} total={9} on_change="page" />|)
    assert pager =~ ~s(aria-current="page")
    assert pager =~ ~s(phx-value-page="5")
    assert pager =~ "ds-pager__gap"
    first = rendered_to_string(~H|<.pagination page={1} total={2} />|)
    assert first =~ ~s(ds-pager__btn ds-pager__btn--prev" aria-label="Previous page" disabled)

    assigns = %{
      menu: [
        %{heading: "Grid"},
        %{id: "grid", label: "Dashboard", icon: "m-menu"},
        %{separator: true},
        %{id: "s", label: "Settings", navigate: "/s", submenu: true},
        %{id: "p", label: "Policy", disabled: true}
      ]
    }

    menu =
      rendered_to_string(
        ~H|<.menu items={@menu} selected="grid" on_select="go" variant={:sidebar} label="Sections" />|
      )

    assert menu =~ ~s(role="navigation")
    assert menu =~ ~s(aria-current="true")
    assert menu =~ ~s(href="/s")
    assert menu =~ "ds-menu__sub"
    assert menu =~ "ds-menu__sep"
    assert menu =~ "ds-menu__heading"
  end

  test "radio and tooltip" do
    assigns = %{}

    assert rendered_to_string(~H|<.radio name="mode" value="live" label="Live" checked />|) =~
             "ds-radio__dot"

    tip = rendered_to_string(~H|<.tooltip text="p95 latency">Latency</.tooltip>|)
    assert tip =~ ~s(role="tooltip")
    assert tip =~ "aria-describedby"
    assert tip =~ ~s(phx-key="escape")
    assert tip =~ "data-dismissed"
  end

  test "theme attrs and switch" do
    assert GosUi.theme_attrs() == [{"data-theme", "tron"}]

    assert GosUi.theme_attrs(:compaq, :light) == [
             {"data-theme", "compaq"},
             {"data-mode", "light"}
           ]

    assigns = %{}

    html =
      rendered_to_string(~H|<.theme_switch theme={:matrix} mode={:light} on_change="theme" />|)

    assert html =~ ~s(phx-change="theme")
    assert html =~ ~s(<option value="matrix" selected>)
    assert html =~ ~s(<option value="light" selected>)
  end

  test "livebook render wraps a component with the stylesheet and sprite" do
    out =
      GosUi.Livebook.render(
        &GosUi.Components.sequential_meter/1,
        [value: 82, warn: 70, label: "cpu"],
        theme: :compaq,
        kino: false
      )

    html = out
    assert html =~ ~s(data-theme="compaq")
    assert html =~ "--status-medium"
    assert html =~ "ds-meter__fill"
    assert html =~ ~s(id="m-critical")
    refute html =~ "@font-face"
  end
end
