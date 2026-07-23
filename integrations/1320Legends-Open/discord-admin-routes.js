/**
 * Web admin panel routes for 1320Legends-Open server.js
 *
 * Mount:
 *   import { registerDiscordAdminRoutes } from "./features/admin/discord-admin-routes.js";
 *   registerDiscordAdminRoutes(app, { store, requireAdmin });
 */

import {
  searchAccountsForAdmin,
  toAdminDiscordRow,
} from "../accounts/account-discord-admin.js";

export function registerDiscordAdminRoutes(app, { store, requireAdmin }) {
  app.get("/admin/api/users/discord-search", requireAdmin, async (req, res) => {
    try {
      const q = String(req.query.q || "").trim();
      const rows = await searchAccountsForAdmin(store, q);
      res.json({
        ok: true,
        query: q,
        users: rows.map(toAdminDiscordRow),
      });
    } catch (err) {
      res.status(500).json({ ok: false, error: err.message || "search failed" });
    }
  });

  app.get("/admin/api/users/:accountId/discord", requireAdmin, async (req, res) => {
    try {
      const account = await store.getAccountById(req.params.accountId);
      if (!account) {
        res.status(404).json({ ok: false, error: "account not found" });
        return;
      }
      res.json({ ok: true, user: toAdminDiscordRow(account) });
    } catch (err) {
      res.status(500).json({ ok: false, error: err.message || "lookup failed" });
    }
  });
}

export function renderDiscordAdminPanelHtml() {
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>1320 Legends Admin — Discord links</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 24px; background: #111; color: #eee; }
    input, button { padding: 8px 12px; font-size: 14px; }
    table { border-collapse: collapse; width: 100%; margin-top: 16px; }
    th, td { border: 1px solid #333; padding: 8px; text-align: left; }
    th { background: #222; }
    a { color: #8ea1ff; }
    .muted { color: #888; }
  </style>
</head>
<body>
  <h1>Discord account links</h1>
  <p class="muted">Shows game accounts that linked Discord via OAuth login.</p>
  <form id="searchForm">
    <input id="q" placeholder="Racer name, account id, Discord id, or Discord username" size="48" />
    <button type="submit">Search</button>
  </form>
  <table>
    <thead>
      <tr>
        <th>Account ID</th>
        <th>Racer name</th>
        <th>Discord username</th>
        <th>Discord ID</th>
        <th>Profile</th>
      </tr>
    </thead>
    <tbody id="rows"></tbody>
  </table>
  <script>
    const form = document.getElementById("searchForm");
    const rows = document.getElementById("rows");
    form.addEventListener("submit", async (e) => {
      e.preventDefault();
      const q = document.getElementById("q").value.trim();
      const res = await fetch("/admin/api/users/discord-search?q=" + encodeURIComponent(q));
      const data = await res.json();
      rows.innerHTML = "";
      if (!data.ok) {
        rows.innerHTML = "<tr><td colspan='5'>Error: " + (data.error || "unknown") + "</td></tr>";
        return;
      }
      if (!data.users.length) {
        rows.innerHTML = "<tr><td colspan='5'>No matches.</td></tr>";
        return;
      }
      for (const u of data.users) {
        const tr = document.createElement("tr");
        tr.innerHTML =
          "<td>" + u.accountId + "</td>" +
          "<td>" + escapeHtml(u.username) + "</td>" +
          "<td>" + (u.discordConnected ? escapeHtml(u.discordUsername || "—") : "<span class='muted'>not linked</span>") + "</td>" +
          "<td>" + (u.discordConnected ? escapeHtml(u.discordId) : "—") + "</td>" +
          "<td>" + (u.discordProfileUrl ? "<a href='" + u.discordProfileUrl + "' target='_blank' rel='noopener'>Open</a>" : "—") + "</td>";
        rows.appendChild(tr);
      }
    });
    function escapeHtml(s) {
      return String(s).replace(/[&<>\"']/g, (c) => ({ "&":"&amp;","<":"&lt;",">":"&gt;","\\"":"&quot;","'":"&#39;" }[c]));
    }
  </script>
</body>
</html>`;
}
