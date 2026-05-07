import { Hono } from "hono";
import { getDb } from "../db/client";
import { requireAuth, type AuthVars } from "../auth/middleware";
import { userToDto, type UserRow } from "../schemas/user";

export const me = new Hono<{ Variables: AuthVars }>();

me.get("/", requireAuth(), (c) => {
  const id = c.get("userId");
  const row = getDb()
    .query<Omit<UserRow, "password_hash">, [string]>(
      "SELECT id, email, display_name, specialization FROM users WHERE id = ?",
    )
    .get(id);
  if (!row) return c.json({ error: "unauthorized" }, 401);
  return c.json(userToDto(row));
});
