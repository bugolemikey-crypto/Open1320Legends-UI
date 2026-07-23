/**
 * Extend getuser XML for in-game Mod Tools (SupportCenter player lookup).
 * Merge into your existing getuser handler in actions.js / features layer.
 */

import { discordFieldsFromAccount } from "./account-discord-admin.js";

export function appendDiscordAttrsToUserNode(userNode, account) {
  const { discordId, discordUsername, discordConnected } = discordFieldsFromAccount(account);

  // Legacy client flag reused for Discord-linked accounts.
  userNode.fbc = discordConnected ? "1" : "0";

  if (discordConnected) {
    userNode.did = discordId;
    userNode.dun = discordUsername;
  }

  return userNode;
}

/** Example XML fragment returned to the Flash client */
export function buildGetUserXml(account, extra = {}) {
  const { discordId, discordUsername, discordConnected } = discordFieldsFromAccount(account);
  const attrs = {
    i: String(account.id),
    u: account.username,
    mb: account.isMember ? "True" : "False",
    fbc: discordConnected ? "1" : "0",
    ...(discordConnected
      ? {
          did: discordId,
          dun: discordUsername,
        }
      : {}),
    ...extra,
  };

  const attrText = Object.entries(attrs)
    .map(([key, value]) => `${key}="${escapeXml(String(value))}"`)
    .join(" ");

  return `<n2><n ${attrText} /></n2>`;
}

function escapeXml(value) {
  return value
    .replace(/&/g, "&amp;")
    .replace(/"/g, "&quot;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}
