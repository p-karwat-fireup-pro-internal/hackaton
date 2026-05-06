import type { Database } from "bun:sqlite";
import { randomBytes, createHash, randomUUID } from "node:crypto";
import { config } from "../config";

function hashToken(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

export type IssuedRefresh = { id: string; token: string };

export function issueRefreshToken(db: Database, userId: string): IssuedRefresh {
  const id = randomUUID();
  const token = randomBytes(32).toString("base64url");
  const now = Date.now();
  const expiresAt = now + config.REFRESH_TTL_SECONDS * 1000;
  db.run(
    `INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at, created_at)
     VALUES (?, ?, ?, ?, ?)`,
    [id, userId, hashToken(token), expiresAt, now],
  );
  return { id, token };
}

export type RotateResult =
  | { kind: "ok"; userId: string; token: string; id: string }
  | { kind: "reused" }
  | { kind: "expired" }
  | { kind: "unknown" };

export function rotateRefreshToken(db: Database, token: string): RotateResult {
  const hash = hashToken(token);
  const row = db
    .query<
      { id: string; user_id: string; expires_at: number; revoked_at: number | null },
      [string]
    >(
      "SELECT id, user_id, expires_at, revoked_at FROM refresh_tokens WHERE token_hash = ?",
    )
    .get(hash);
  if (!row) return { kind: "unknown" };
  if (row.revoked_at !== null) {
    revokeAllForUser(db, row.user_id);
    return { kind: "reused" };
  }
  if (row.expires_at < Date.now()) return { kind: "expired" };

  db.run("UPDATE refresh_tokens SET revoked_at = ? WHERE id = ?", [Date.now(), row.id]);
  const next = issueRefreshToken(db, row.user_id);
  return { kind: "ok", userId: row.user_id, token: next.token, id: next.id };
}

export function revokeAllForUser(db: Database, userId: string): void {
  db.run(
    "UPDATE refresh_tokens SET revoked_at = ? WHERE user_id = ? AND revoked_at IS NULL",
    [Date.now(), userId],
  );
}

export function revokeByToken(db: Database, token: string): void {
  db.run("UPDATE refresh_tokens SET revoked_at = ? WHERE token_hash = ? AND revoked_at IS NULL", [
    Date.now(),
    hashToken(token),
  ]);
}
