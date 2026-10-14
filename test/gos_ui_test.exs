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
end
