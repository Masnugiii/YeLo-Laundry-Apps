import { AxiosError } from "axios";
import type { ApiEnvelope } from "@/types/api";

export function getErrorMessage(error: unknown, fallback: string) {
  if (error instanceof AxiosError) {
    const envelope = error.response?.data as ApiEnvelope<unknown> | undefined;
    if (envelope?.message) return envelope.message;
    if (error.message) return error.message;
  }

  if (error instanceof Error && error.message) {
    return error.message;
  }

  return fallback;
}
