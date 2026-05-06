import { describe, it, expect } from "bun:test";
import { signAccessToken, verifyAccessToken } from "../src/auth/jwt";

describe("JWT access tokens", () => {
  it("round-trips a valid token", async () => {
    const token = await signAccessToken({ sub: "u-1", email: "a@b.pl" });
    const claims = await verifyAccessToken(token);
    expect(claims.sub).toBe("u-1");
    expect(claims.email).toBe("a@b.pl");
    expect(typeof claims.exp).toBe("number");
  });

  it("rejects a tampered token", async () => {
    const token = await signAccessToken({ sub: "u-1", email: "a@b.pl" });
    const tampered = token.slice(0, -2) + "xx";
    await expect(verifyAccessToken(tampered)).rejects.toThrow();
  });
});
