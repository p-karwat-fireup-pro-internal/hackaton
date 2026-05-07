export type UserRow = {
  id: string;
  email: string;
  password_hash: string;
  display_name: string;
  specialization: string;
};

export type UserDTO = {
  id: string;
  email: string;
  displayName: string;
  specialization: string;
};

export function userToDto(r: Pick<UserRow, "id" | "email" | "display_name" | "specialization">): UserDTO {
  return {
    id: r.id,
    email: r.email,
    displayName: r.display_name,
    specialization: r.specialization,
  };
}
