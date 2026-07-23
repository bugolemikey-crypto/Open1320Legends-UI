/**
 * server.js additions for 1320Legends-Open
 *
 * 1) Persist Discord on create/link (you likely already do in handleCreateAccount):
 *      discordId, discordUsername from getAuthorizedDiscordUser()
 *
 * 2) Register admin routes + page:
 */

import {
  registerDiscordAdminRoutes,
  renderDiscordAdminPanelHtml,
} from "./features/admin/discord-admin-routes.js";

export function registerDiscordAdmin(app, deps) {
  registerDiscordAdminRoutes(app, deps);

  app.get("/admin/discord-users", deps.requireAdmin, (_req, res) => {
    res.type("html").send(renderDiscordAdminPanelHtml());
  });
}

/*
  registerDiscordAdmin(app, { store, requireAdmin });

Admin panel URL:
  https://your-server/admin/discord-users

Search supports racer name, account id, Discord username, or Discord id
(for users who linked via OAuth login).
*/
