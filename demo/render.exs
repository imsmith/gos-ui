# demo/render.exs — every GosUi component on one page. `make demo` renders and serves it.
import Phoenix.Component
import Phoenix.LiveViewTest, only: [rendered_to_string: 1]
import GosUi.Components
assigns = %{
  cells: (for i <- 0..47, do: %{id: "n#{i}", value: rem(i * 7, 13) - 6 + if(i in [5, 19], do: 10, else: 0), label: "node-#{i}"}),
  tabs: [%{id: "grid", label: "Grid", icon: "m-menu"}, %{id: "alerts", label: "Alerts", count: 3}, %{id: "nodes", label: "Nodes", disabled: true}],
  series: [12, 14, 13, 18, 22, 21, 27, 31, 30, 38, 44, 47],
  log: [
    %{id: 1, ts: "02:13:50Z", severity: :info, msg: "Rebooted node-12. Telemetry nominal."},
    %{id: 2, ts: "02:14:02Z", severity: :medium, msg: "Latency 41ms on node-13, above 40ms threshold. Sustained 12m."},
    %{id: 3, ts: "02:14:20Z", severity: :high, msg: "Replica lag 42 s. Primary under write burst. Check db-03 before failover."},
    %{id: 4, ts: "02:14:31Z", severity: :critical, msg: "Uplink down — sector 12. 4 nodes unreachable for 4m. Reroute or restore the uplink."},
    %{id: 5, ts: "02:14:40Z", severity: :low, msg: "Reroute applied. 3 of 4 nodes reachable."}
  ],
  nodes: [%{id: "node-11", step: :low, cpu: 42, lat: 18}, %{id: "node-12", step: :medium, cpu: 78, lat: 41}, %{id: "node-13", step: :critical, cpu: 97, lat: 212}],
  crumbs: [%{label: "Grid", href: "#"}, %{label: "Sector 12", href: "#"}, %{label: "node-13"}],
  menu: [%{heading: "Grid"}, %{id: "grid", label: "Dashboard", icon: "m-menu"}, %{id: "alerts", label: "Alerts", icon: "m-bell", hint: 3}, %{separator: true}, %{id: "settings", label: "Settings", icon: "m-settings", submenu: true}, %{id: "policy", label: "Policy", icon: "m-lock", disabled: true}]
}
body = rendered_to_string(~H"""
<.sprite />
<div style="padding:24px;display:flex;flex-direction:column;gap:20px;max-width:1040px">
  <div style="height:260px;border:1px solid var(--border)">
    <.app_shell>
      <:brand><.mark name="m-settings" size={18} /> GRID·OPS</:brand>
      <:summary><.status_badge step={:critical} label="2 DOWN" pulse /><.status_badge step={:medium} label="5 WARN" /><.status_badge step={:low} label="61 OK" /></:summary>
      <:meta><.freshness state={:live} at="02:14:31Z" /></:meta>
      <:actions><.button variant={:text} size={:sm} icon="m-bell" aria-label="Notifications">3</.button></:actions>
      <:nav><.menu variant={:sidebar} items={@menu} selected="alerts" on_select="go" /></:nav>
      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:12px">
        <.stat_tile label="CPU node-13" value={97} unit="%" delta={4} delta_unit="pt" step={:critical}><.sparkline data={@series} /><.status_badge step={:critical} variant={:plain} size={13} /></.stat_tile>
        <.stat_tile label="Replica lag" value={42} unit="s" delta={-3} delta_unit="s" step={:medium}><.sparkline data={Enum.reverse(@series)} /></.stat_tile>
        <.stat_tile label="Nodes online" value={61} unit="/ 64" delta={0}><.freshness state={:stale} at="01:58:04Z" /></.stat_tile>
      </div>
    </.app_shell>
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;align-items:start">
    <.key_value columns={2}><:item key="Node">node-13</:item><:item key="Status"><.status_badge step={:critical} variant={:plain} size={13} /></:item><:item key="CPU" num>97%</:item><:item key="Region"><.tag>us-east</.tag></:item><:item key="Uptime" num>14d 02:14</:item><:item key="Kernel">6.12.107</:item></.key_value>
    <.log_view id="log" lines={@log} height="12rem" />
  </div>
  <.breadcrumb items={@crumbs} />
  <.tabs tabs={@tabs} active="alerts" select="tab" />
  <.table rows={@nodes} selected="node-13" on_select="pick" sort={%{key: "cpu", dir: :descending}} on_sort="sort" density={:compact}>
    <:col :let={n} key="id" label="Node" sortable>{n.id}</:col>
    <:col :let={n} key="step" label="Status"><.status_badge step={n.step} variant={:plain} size={13} /></:col>
    <:col :let={n} key="cpu" label="CPU %" num sortable>{n.cpu}</:col>
    <:col :let={n} key="lat" label="Latency ms" num><.tooltip text="p95 round-trip to the collector">{n.lat}</.tooltip></:col>
  </.table>
  <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px">
    <.state_panel mode={:empty} title="No alerts in sector 12"><:action><.button variant={:ghost} size={:sm} icon="m-add">Create rule</.button></:action>Nothing crossed a threshold in 24h.</.state_panel>
    <.state_panel mode={:loading} title="Loading telemetry"><.skeleton lines={3} /></.state_panel>
    <.state_panel mode={:error} title="Telemetry unavailable"><:action><.button variant={:ghost} size={:sm} icon="m-refresh">Retry</.button></:action>Collector db-03 timed out after 30s.</.state_panel>
  </div>
  <div style="display:flex;gap:24px;align-items:flex-start">
    <.menu items={@menu} selected="alerts" on_select="go" label="Sections" />
    <.pagination page={4} total={9} on_change="page" />
    <div style="display:flex;flex-direction:column;gap:8px"><.radio name="mode" value="live" label="Live" checked /><.radio name="mode" value="replay" label="Replay" /></div>
    <.theme_switch on_change="theme" />
  </div>
  <.modal id="confirm" show destructive title="Delete cluster prod-east">
    Deletes 14 nodes and their volumes. This cannot be undone.
    <:footer><.button variant={:ghost} phx-click={hide_modal("confirm")}>Cancel</.button><.button variant={:danger} icon="m-delete" phx-click="delete">Delete cluster</.button></:footer>
  </.modal>
  <.toast_stack><.toast id="t-crit" severity={:critical} title="Uplink down — sector 12." dismiss="ack">Acknowledge to clear.</.toast><.toast id="t-low" severity={:low} title="Rebooted node-12." dismiss="x" /></.toast_stack>
  <div style="display:flex;gap:12px;align-items:center">
    <.tag icon="m-lock">TLP:AMBER</.tag><.tag accent>SECTOR-12</.tag><.tag remove="rm">region=us-east</.tag>
    <.sparkline data={@series} /> <.sparkline data={@series} mode={:threshold} warn={40} crit={60} unit="ms" />
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px">
    <.diverging_meter value={2.0} range={5} label="temp drift" unit="σ" />
    <.sequential_meter value={82} warn={70} crit={90} label="cpu node-13" />
    <.diverging_meter value={-4.5} label="pressure" />
    <.sequential_meter value={96} warn={70} crit={90} label="disk" />
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;align-items:start">
    <.heatmap cells={@cells} columns={12} select="pick" />
    <div style="display:flex;flex-direction:column;gap:12px">
      <.input label="Port" name="port" value="99999" icon="m-settings" error="Port out of range. Use 1–65535." />
      <.input label="Search" name="q" icon="m-search" placeholder="node id" helper="Prefix match." />
      <.select label="Sector" name="sector" options={["11", "12", {"Thirteen", "13"}]} value="12" />
      <div style="display:flex;gap:20px"><.checkbox label="Acknowledge" name="ack" checked /><.toggle label="Live" checked show_state /><.toggle label="Mute" show_state /></div>
    </div>
  </div>
</div>
""")
File.write!("demo/index.html", ~s"""
<!doctype html><html lang="en" data-theme="tron"><head><meta charset="utf-8">
<link rel="stylesheet" href="../priv/static/gos-ui/styles.css">
<script type="module">
  import { GosUiHooks } from "../priv/static/gos-ui/gos-ui.js";
  for (const el of document.querySelectorAll("[phx-hook=GosUiToast]")) GosUiHooks.GosUiToast.mounted.call({ el });
  for (const el of document.querySelectorAll("[phx-hook=GosUiLog]")) GosUiHooks.GosUiLog.mounted.call({ el });
</script></head><body>#{body}</body></html>
""")
IO.puts("wrote #{byte_size(body)} bytes")
