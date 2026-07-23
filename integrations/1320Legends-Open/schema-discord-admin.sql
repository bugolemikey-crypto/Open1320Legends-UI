-- Add to your accounts table in 1320Legends-Open (adjust table/column names to match your store).

ALTER TABLE accounts ADD COLUMN discord_id TEXT;
ALTER TABLE accounts ADD COLUMN discord_username TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS idx_accounts_discord_id
  ON accounts(discord_id)
  WHERE discord_id IS NOT NULL AND discord_id != '';
