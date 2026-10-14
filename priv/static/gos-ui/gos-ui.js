// gos-ui.js — the small client side of GosUi. Register the hooks with your
// LiveSocket:  new LiveSocket("/live", Socket, { hooks: { ...GosUiHooks } })
//
// GosUiToast: honors data-duration on a toast (ms; 0 = persist, critical is
// always 0 server-side). On timeout it clicks the toast's own dismiss button,
// so the same server event or JS command runs as for a manual dismiss; with
// no dismiss button it just hides the element. Hovering pauses the timer.
export const GosUiHooks = {
  GosUiToast: {
    mounted() {
      const ms = parseInt(this.el.dataset.duration || "0", 10);
      if (!ms) return;
      this.timer = setTimeout(() => {
        const x = this.el.querySelector(".ds-toast__x");
        if (x) x.click(); else this.el.style.display = "none";
      }, ms);
      this.el.addEventListener("mouseenter", () => clearTimeout(this.timer));
    },
    destroyed() { clearTimeout(this.timer); },
  },
};
