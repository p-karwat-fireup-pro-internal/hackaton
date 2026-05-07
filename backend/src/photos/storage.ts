import { mkdirSync, writeFileSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { config } from "../config";

let _basePathOverride: string | null = null;

export function setPhotosPathForTests(path: string | null): void {
  _basePathOverride = path;
}

function basePath(): string {
  return _basePathOverride ?? config.PHOTOS_PATH;
}

export function writePhoto(
  userId: string,
  jobId: string,
  photoId: string,
  ext: string,
  bytes: Uint8Array,
): string {
  const dir = join(basePath(), userId, jobId);
  mkdirSync(dir, { recursive: true });
  const filename = `${photoId}.${ext}`;
  writeFileSync(join(dir, filename), bytes);
  return join(userId, jobId, filename);
}

export function readPhoto(relPath: string): Uint8Array | null {
  try {
    return readFileSync(join(basePath(), relPath));
  } catch (e) {
    if ((e as NodeJS.ErrnoException).code === "ENOENT") return null;
    throw e;
  }
}
