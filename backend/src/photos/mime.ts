export type AllowedMime = "image/jpeg" | "image/png" | "image/heic";

const MIMES: ReadonlyArray<{
  mime: AllowedMime;
  ext: string;
  magic: readonly number[];
  offset: number;
}> = [
  { mime: "image/jpeg", ext: "jpg",  magic: [0xff, 0xd8, 0xff], offset: 0 },
  { mime: "image/png",  ext: "png",  magic: [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a], offset: 0 },
  { mime: "image/heic", ext: "heic", magic: [0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x63], offset: 4 },
];

export function sniffMime(bytes: Uint8Array): AllowedMime | null {
  for (const m of MIMES) {
    if (bytes.length < m.offset + m.magic.length) continue;
    if (m.magic.every((b, i) => bytes[m.offset + i] === b)) return m.mime;
  }
  return null;
}

export function extensionFor(mime: AllowedMime): string {
  return MIMES.find((m) => m.mime === mime)!.ext;
}
