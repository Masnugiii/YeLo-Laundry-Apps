import { getStoredToken } from "@/lib/api";

export function getStoredUserRoles(): string[] {
  const token = getStoredToken();
  if (!token) return [];

  try {
    const payload = JSON.parse(atob(token.split(".")[1] ?? ""));
    return Array.isArray(payload.roles) ? payload.roles : [];
  } catch {
    return [];
  }
}

export function isOwnerRole(): boolean {
  return getStoredUserRoles().includes("OWNER");
}
