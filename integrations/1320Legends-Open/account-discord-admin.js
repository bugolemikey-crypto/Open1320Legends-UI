/**
 * Drop into 1320Legends-Open account store / repository layer.
 * Wire createAccount, linkDiscordAccount, and login paths to these fields.
 */

export function discordFieldsFromAccount(account) {
  const discordId = account?.discordId || account?.discord_id || "";
  const discordUsername = account?.discordUsername || account?.discord_username || "";
  return {
    discordId: String(discordId || ""),
    discordUsername: String(discordUsername || ""),
    discordConnected: Boolean(discordId),
  };
}

export async function findAccountByDiscordId(store, discordId) {
  if (!discordId) return null;
  return store.findAccountByDiscordId?.(String(discordId)) ?? null;
}

export async function linkDiscordToAccount(store, accountId, discordUser) {
  return store.updateAccount(accountId, {
    discordId: String(discordUser.discordId || discordUser.id || ""),
    discordUsername: String(discordUser.discordUsername || discordUser.username || ""),
  });
}

export async function clearDiscordFromAccount(store, accountId) {
  return store.updateAccount(accountId, {
    discordId: "",
    discordUsername: "",
  });
}

/** For web admin search: username, account id, or discord id/username */
export async function searchAccountsForAdmin(store, query) {
  const q = String(query || "").trim();
  if (!q) return [];

  if (store.searchAccountsForAdmin) {
    return store.searchAccountsForAdmin(q);
  }

  const byName = (await store.findAccountsByUsernamePrefix?.(q)) || [];
  const byDiscord = (await store.findAccountsByDiscord?.(q)) || [];
  const merged = new Map();
  for (const row of [...byName, ...byDiscord]) {
    merged.set(row.id || row.accountId, row);
  }
  return [...merged.values()];
}

export function toAdminDiscordRow(account) {
  const { discordId, discordUsername, discordConnected } = discordFieldsFromAccount(account);
  return {
    accountId: account.id || account.accountId,
    username: account.username,
    email: account.email || "",
    discordConnected,
    discordId,
    discordUsername,
    discordProfileUrl: discordId ? `https://discord.com/users/${discordId}` : "",
  };
}
