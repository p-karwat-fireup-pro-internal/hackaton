import { describe, it, expect } from "bun:test";
import { hashPassword, verifyPassword } from "../src/auth/passwords";

describe("password hashing", () => {
  it("verifies a correct password", async () => {
    const hash = await hashPassword("test1234");
    expect(await verifyPassword(hash, "test1234")).toBe(true);
  });

  it("rejects a wrong password", async () => {
    const hash = await hashPassword("test1234");
    expect(await verifyPassword(hash, "wrong")).toBe(false);
  });

  it("returns argon2id hashes", async () => {
    const hash = await hashPassword("test1234");
    expect(hash.startsWith("$argon2id$")).toBe(true);
  });
});
