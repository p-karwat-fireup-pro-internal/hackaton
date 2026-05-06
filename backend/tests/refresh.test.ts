import { describe, it, expect, beforeEach } from "bun:test";
import { Database } from "bun:sqlite";
import { runMigrations } from "../src/db/migrate";
import { issueRefreshToken, rotateRefreshToken, revokeAllForUser } from "../src/auth/refreshTokens";

let db: Database;
beforeEach(() => {
  db = new Database(":memory:");
  runMigrations(db);
  db.run(
    "INSERT INTO users (id, email, password_hash, display_name, specialization, created_at) VALUES (?,?,?,?,?,?)",
    ["u-1", "a@b.pl", "x", "A", "elektryk", Date.now()],
  );
});

describe("refresh token store", () => {
  it("issues a new token and stores its hash", () => {
    const { token, id } = issueRefreshToken(db, "u-1");
    expect(token.length).toBeGreaterThan(20);
    const row = db.query<{ id: string }, [string]>("SELECT id FROM refresh_tokens WHERE id = ?").get(id);
    expect(row?.id).toBe(id);
  });

  it("rotates: old token marked revoked, new token issued", () => {
    const first = issueRefreshToken(db, "u-1");
    const result = rotateRefreshToken(db, first.token);
    expect(result.kind).toBe("ok");
    if (result.kind !== "ok") return;
    const oldRow = db
      .query<{ revoked_at: number | null }, [string]>("SELECT revoked_at FROM refresh_tokens WHERE id = ?")
      .get(first.id);
    expect(oldRow?.revoked_at).not.toBeNull();
    expect(result.token).not.toBe(first.token);
  });

  it("detects reuse: rotating an already-revoked token revokes ALL of user's tokens", () => {
    const first = issueRefreshToken(db, "u-1");
    const second = issueRefreshToken(db, "u-1");
    rotateRefreshToken(db, first.token); // legitimately rotate first
    const reuse = rotateRefreshToken(db, first.token); // attacker reuses old
    expect(reuse.kind).toBe("reused");
    const live = db
      .query<{ c: number }, [string]>(
        "SELECT COUNT(*) AS c FROM refresh_tokens WHERE user_id = ? AND revoked_at IS NULL",
      )
      .get("u-1");
    expect(live?.c).toBe(0);
  });

  it("revokeAllForUser kills every live token", () => {
    issueRefreshToken(db, "u-1");
    issueRefreshToken(db, "u-1");
    revokeAllForUser(db, "u-1");
    const live = db
      .query<{ c: number }, [string]>(
        "SELECT COUNT(*) AS c FROM refresh_tokens WHERE user_id = ? AND revoked_at IS NULL",
      )
      .get("u-1");
    expect(live?.c).toBe(0);
  });
});
