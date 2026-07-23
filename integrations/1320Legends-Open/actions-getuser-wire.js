/**
 * Wire into 1320Legends-Open actions.js (or your getuser handler).
 *
 * After loading the account record for tid/accountId, merge Discord attrs
 * into the XML the Flash client already consumes.
 */

import { appendDiscordAttrsToUserNode } from "./getuser-discord.js";

export function enrichGetUserPayload(userNode, account) {
  return appendDiscordAttrsToUserNode(userNode, account);
}

/*
Example inside handleGetUser:

  const account = await store.getAccountById(tid);
  const userNode = {
    i: String(account.id),
    u: account.username,
    sc: String(account.streetCredit ?? 0),
    ti: String(account.teamId ?? 0),
    tn: account.teamName ?? "",
    mb: account.isMember ? "True" : "False",
  };
  enrichGetUserPayload(userNode, account);
  return xmlFromUserNode(userNode);

Flash Mod Tools can read:
  fbc=1  -> Discord linked
  dun    -> Discord username
  did    -> Discord snowflake id
*/
