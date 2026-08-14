import { AxiosError } from "axios";
import type { ApiEnvelope } from "@/types/api";

export function getErrorMessage(error: unknown, fallback: string) {
  if (error instanceof AxiosError) {
    const envelope = error.response?.data as ApiEnvelope<unknown> | undefined;
    if (envelope?.message) {
      if (Array.isArray(envelope.errors) && envelope.errors.length > 0) {
        return `${envelope.message}: ${envelope.errors.join(", ")}`;
      }
      if (
        envelope.errors &&
        typeof envelope.errors === "object" &&
        !Array.isArray(envelope.errors) &&
        Object.keys(envelope.errors).length > 0
      ) {
        return `${envelope.message}: ${JSON.stringify(envelope.errors)}`;
      }
      return envelope.message;
    }
    if (error.message) return error.message;
  }

  if (error instanceof Error && error.message) {
    return error.message;
  }

  return fallback;
}
