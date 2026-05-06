import { sign, verify } from "hono/jwt";
import { config } from "../config";

export type AccessClaims = {
  sub: string;   // user id
  email: string;
  iat: number;
  exp: number;
};

export async function signAccessToken(payload: { sub: string; email: string }): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  return sign(
    { ...payload, iat: now, exp: now + config.ACCESS_TTL_SECONDS },
    config.JWT_SECRET,
    "HS256",
  );
}

export async function verifyAccessToken(token: string): Promise<AccessClaims> {
  return (await verify(token, config.JWT_SECRET, "HS256")) as AccessClaims;
}
