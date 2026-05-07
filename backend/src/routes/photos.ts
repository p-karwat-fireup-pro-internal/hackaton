import { Hono } from "hono";
import { randomUUID } from "node:crypto";
import { getDb } from "../db/client";
import { requireAuth, type AuthVars } from "../auth/middleware";
import { extensionFor, sniffMime } from "../photos/mime";
import { writePhoto, readPhoto } from "../photos/storage";
import { photoToDto, UploadPhotoBody, type PhotoRow } from "../schemas/photo";
import { loadOwnedJob } from "./jobs";

const MAX_SIZE = 5 * 1024 * 1024;

export const jobPhotos = new Hono<{ Variables: AuthVars }>();
export const photoFiles = new Hono<{ Variables: AuthVars }>();

jobPhotos.use("*", requireAuth());
photoFiles.use("*", requireAuth());

jobPhotos.get("/:jobId/photos", (c) => {
  const userId = c.get("userId");
  const jobId = c.req.param("jobId");
  if (!loadOwnedJob(userId, jobId)) return c.json({ error: "not_found" }, 404);
  const rows = getDb()
    .query<PhotoRow, [string]>("SELECT * FROM photos WHERE job_id = ? ORDER BY taken_at ASC")
    .all(jobId);
  return c.json(rows.map(photoToDto));
});

jobPhotos.post("/:jobId/photos", async (c) => {
  const userId = c.get("userId");
  const jobId = c.req.param("jobId");
  if (!loadOwnedJob(userId, jobId)) return c.json({ error: "not_found" }, 404);

  const form = await c.req.formData().catch(() => null);
  if (!form) return c.json({ error: "invalid_request" }, 400);
  const file = form.get("file");
  const description = form.get("description");
  if (!(file instanceof File) || typeof description !== "string") {
    return c.json({ error: "invalid_request" }, 400);
  }
  if (file.size > MAX_SIZE) return c.json({ error: "file_too_large" }, 413);
  const parsed = UploadPhotoBody.safeParse({ description });
  if (!parsed.success) return c.json({ error: "invalid_request" }, 400);

  const bytes = new Uint8Array(await file.arrayBuffer());
  const mime = sniffMime(bytes);
  if (!mime) return c.json({ error: "unsupported_media_type" }, 415);

  const id = randomUUID();
  const filename = writePhoto(userId, jobId, id, extensionFor(mime), bytes);
  const takenAt = Date.now();
  const row: PhotoRow = {
    id,
    job_id: jobId,
    description: parsed.data.description,
    filename,
    mime_type: mime,
    size_bytes: bytes.length,
    taken_at: takenAt,
    uploaded_by: userId,
  };
  getDb().run(
    `INSERT INTO photos (id, job_id, description, filename, mime_type, size_bytes, taken_at, uploaded_by)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [row.id, row.job_id, row.description, row.filename, row.mime_type, row.size_bytes, row.taken_at, row.uploaded_by],
  );
  return c.json(photoToDto(row), 201);
});

photoFiles.get("/:id/file", (c) => {
  const userId = c.get("userId");
  const id = c.req.param("id");
  const row = getDb()
    .query<PhotoRow, [string]>("SELECT * FROM photos WHERE id = ?")
    .get(id);
  if (!row || row.uploaded_by !== userId) return c.json({ error: "not_found" }, 404);
  const bytes = readPhoto(row.filename);
  if (!bytes) return c.json({ error: "not_found" }, 404);
  return new Response(bytes, { headers: { "Content-Type": row.mime_type } });
});
