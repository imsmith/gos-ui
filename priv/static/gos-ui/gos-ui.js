// gos-ui.js — the small client side of GosUi. Register the hooks with your
// LiveSocket:  new LiveSocket("/live", Socket, { hooks: { ...GosUiHooks } })
//
// GosUiToast: honors data-duration on a toast (ms; 0 = persist, critical is
// always 0 server-side). On timeout it clicks the toast's own dismiss button,
// so the same server event or JS command runs as for a manual dismiss; with
// no dismiss button it just hides the element. Hovering pauses the timer.
//
// GosUiLog: tail-following for a log view. Follows new lines while scrolled to
// the bottom; scrolling up pauses and reveals the "Paused · n new" button,
// which jumps back to the tail and resumes.
export const GosUiHooks = {
  GosUiLog: {
    mounted() {
      const el = this.el;
      const btn = el.querySelector(".ds-log__paused");
      const atBottom = () => el.scrollHeight - el.scrollTop - el.clientHeight < 4;
      this.paused = false; this.unseen = 0;
      const render = () => { if (btn) { btn.hidden = !this.paused; btn.textContent = `Paused${this.unseen ? " · " + this.unseen + " new" : ""} ↓`; } };
      el.scrollTop = el.scrollHeight;
      el.addEventListener("scroll", () => { this.paused = !atBottom(); if (!this.paused) this.unseen = 0; render(); });
      if (btn) btn.addEventListener("click", () => { el.scrollTop = el.scrollHeight; this.paused = false; this.unseen = 0; render(); });
      this.render = render;
    },
    updated() {
      if (this.paused) { this.unseen += 1; this.render(); } else { this.el.scrollTop = this.el.scrollHeight; }
    },
  },
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
