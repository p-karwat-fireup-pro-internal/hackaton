import { Hono, type Context } from "hono";
import { getDb } from "../db/client";
import { requireAuth, type AuthVars } from "../auth/middleware";
import { jobToDto, type JobRow, type JobStatus } from "../schemas/job";

export const jobs = new Hono<{ Variables: AuthVars }>();

jobs.use("*", requireAuth());

export function loadOwnedJob(userId: string, id: string): JobRow | null {
  return getDb()
    .query<JobRow, [string, string]>(
      "SELECT * FROM jobs WHERE id = ? AND technician_id = ?",
    )
    .get(id, userId);
}

jobs.get("/", (c) => {
  const id = c.get("userId");
  const rows = getDb()
    .query<JobRow, [string]>(
      `SELECT * FROM jobs WHERE technician_id = ?
       ORDER BY (status = 'done') ASC, scheduled_start ASC`,
    )
    .all(id);
  return c.json(rows.map(jobToDto));
});

jobs.get("/:id", (c) => {
  const row = loadOwnedJob(c.get("userId"), c.req.param("id"));
  if (!row) return c.json({ error: "not_found" }, 404);
  return c.json(jobToDto(row));
});

function transitionTo(from: JobStatus, to: JobStatus) {
  return (c: Context<{ Variables: AuthVars }>) => {
    const id = c.req.param("id")!;
    const row = loadOwnedJob(c.get("userId"), id);
    if (!row) return c.json({ error: "not_found" }, 404);
    if (row.status !== from) return c.json({ error: "invalid_transition", current: row.status }, 409);
    const now = Date.now();
    getDb().run("UPDATE jobs SET status = ?, updated_at = ? WHERE id = ?", [to, now, id]);
    return c.json(jobToDto({ ...row, status: to, updated_at: now }));
  };
}

jobs.post("/:id/start", transitionTo("pending", "in_progress"));
jobs.post("/:id/complete", transitionTo("in_progress", "done"));
