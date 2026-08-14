import { useMutation } from "@tanstack/react-query";
import { apiPost } from "@/lib/api";
import type {
  DevGenerateOtpInput,
  DevGenerateOtpResult,
} from "@/types/otp-testing";

export function useGenerateDevOtp() {
  return useMutation({
    mutationFn: (input: DevGenerateOtpInput) =>
      apiPost<DevGenerateOtpResult>("/dev/otp/generate", input),
  });
}
