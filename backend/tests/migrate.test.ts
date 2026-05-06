import { describe, it, expect } from "bun:test";
import { Database } from "bun:sqlite";
import { runMigrations } from "../src/db/migrate";

describe("runMigrations", () => {
  it("creates all tables on a fresh DB", () => {
    const db = new Database(":memory:");
    runMigrations(db);

    const tables = db
      .query<{ name: string }, []>("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
      .all()
      .map((r) => r.name);

    expect(tables).toContain("users");
    expect(tables).toContain("refresh_tokens");
    expect(tables).toContain("jobs");
    expect(tables).toContain("photos");
    expect(tables).toContain("meta");
  });

  it("is idempotent — running twice leaves schema_version stable", () => {
    const db = new Database(":memory:");
    const v1 = runMigrations(db);
    const v2 = runMigrations(db);
    expect(v1).toBe(v2);
    expect(v1).toBeGreaterThan(0);
  });
});

describe("002_photos_job_index", () => {
  it("creates idx_photos_job on photos(job_id)", () => {
    const db = new Database(":memory:");
    runMigrations(db);

    const idx = db
      .query<{ name: string; tbl_name: string }, []>(
        "SELECT name, tbl_name FROM sqlite_master WHERE type = 'index' AND name = 'idx_photos_job'",
      )
      .get();

    expect(idx?.name).toBe("idx_photos_job");
    expect(idx?.tbl_name).toBe("photos");
  });

  it("advances schema_version to at least 2", () => {
    const db = new Database(":memory:");
    const v = runMigrations(db);
    expect(v).toBeGreaterThanOrEqual(2);
  });
});
