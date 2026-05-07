const OPTIONS = { algorithm: "argon2id" } as const;

export async function hashPassword(plain: string): Promise<string> {
  return Bun.password.hash(plain, OPTIONS);
}

export async function verifyPassword(hash: string, plain: string): Promise<boolean> {
  try {
    return await Bun.password.verify(plain, hash);
  } catch {
    return false;
  }
}

// Equalizes verification time on the unknown-user branch of /auth/login so
// request timing does not reveal whether an e-mail is registered.
export const DUMMY_HASH: string = await hashPassword(
  "__field-notebook-dummy-hash-do-not-use__",
);
