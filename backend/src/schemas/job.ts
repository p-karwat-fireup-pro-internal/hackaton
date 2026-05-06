import { z } from "zod";

export const JobStatus = z.enum(["pending", "in_progress", "done"]);
export type JobStatus = z.infer<typeof JobStatus>;

export const JobPriority = z.enum(["normal", "urgent"]);
export type JobPriority = z.infer<typeof JobPriority>;

export type JobRow = {
  id: string;
  ticket_id: string;
  technician_id: string;
  category: string;
  address: string;
  unit: string | null;
  district: string | null;
  description: string;
  scheduled_window: string;
  scheduled_start: string;
  estimated_duration_min: number;
  status: JobStatus;
  priority: JobPriority;
  contact_name: string | null;
  contact_phone: string | null;
  travel_time_min: number | null;
  is_new: number;
  created_at: number;
  updated_at: number;
};

export type JobDTO = {
  id: string;
  ticketId: string;
  category: string;
  address: string;
  unit: string | null;
  district: string | null;
  description: string;
  scheduledWindow: string;
  scheduledStart: string;
  estimatedDurationMin: number;
  status: JobStatus;
  priority: JobPriority;
  contactName: string | null;
  contactPhone: string | null;
  travelTimeMin: number | null;
  isNew: boolean;
};

export function jobToDto(r: JobRow): JobDTO {
  return {
    id: r.id,
    ticketId: r.ticket_id,
    category: r.category,
    address: r.address,
    unit: r.unit,
    district: r.district,
    description: r.description,
    scheduledWindow: r.scheduled_window,
    scheduledStart: r.scheduled_start,
    estimatedDurationMin: r.estimated_duration_min,
    status: r.status,
    priority: r.priority,
    contactName: r.contact_name,
    contactPhone: r.contact_phone,
    travelTimeMin: r.travel_time_min,
    isNew: r.is_new === 1,
  };
}
