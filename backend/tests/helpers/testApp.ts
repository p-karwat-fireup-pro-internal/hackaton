import { Hono } from "hono";
import { Database } from "bun:sqlite";
import { runMigrations } from "../../src/db/migrate";
import { setDbForTests } from "../../src/db/client";
import { seed } from "../../src/db/seed";
import { health } from "../../src/routes/health";
import { auth } from "../../src/routes/auth";
import { me } from "../../src/routes/me";
import { jobs } from "../../src/routes/jobs";

export async function buildApp() {
  const db = new Database(":memory:");
  runMigrations(db);
  setDbForTests(db);
  await seed(db);
  const app = new Hono();
  app.route("/health", health);
  app.route("/auth", auth);
  app.route("/me", me);
  app.route("/jobs", jobs);
  return { app, db };
}
