import { mkdirSync, writeFileSync, readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { config } from "../config";

export function writePhoto(
  userId: string,
  jobId: string,
  photoId: string,
  ext: string,
  bytes: Uint8Array,
): string {
  const dir = join(config.PHOTOS_PATH, userId, jobId);
  mkdirSync(dir, { recursive: true });
  const filename = `${photoId}.${ext}`;
  writeFileSync(join(dir, filename), bytes);
  return join(userId, jobId, filename);
}

export function readPhoto(relPath: string): Uint8Array | null {
  const abs = join(config.PHOTOS_PATH, relPath);
  if (!existsSync(abs)) return null;
  return readFileSync(abs);
}
