import { z } from "zod";

export const UploadPhotoBody = z.object({
  description: z.string().min(1).max(500),
});

export type PhotoRow = {
  id: string;
  job_id: string;
  description: string;
  filename: string;
  mime_type: string;
  size_bytes: number;
  taken_at: number;
  uploaded_by: string;
};

export type PhotoDTO = {
  id: string;
  jobId: string;
  description: string;
  mimeType: string;
  sizeBytes: number;
  takenAt: number;
};

export function photoToDto(r: PhotoRow): PhotoDTO {
  return {
    id: r.id,
    jobId: r.job_id,
    description: r.description,
    mimeType: r.mime_type,
    sizeBytes: r.size_bytes,
    takenAt: r.taken_at,
  };
}
