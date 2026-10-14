defmodule GosUiTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest, only: [rendered_to_string: 1]
  import GosUi.Components

  test "tokens come from the vendored module" do
    assert GosUi.Tokens.status().treatment.always_fill == [:critical]
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
    assert GosUi.Livebook.scale(:status) |> hd() == "#ff2740"
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
end
