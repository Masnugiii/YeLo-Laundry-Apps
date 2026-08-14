export type OtpTestingPurpose = "login" | "register" | "password_reset";

export interface DevGenerateOtpInput {
  phone: string;
  purpose: OtpTestingPurpose;
}

export interface DevGenerateOtpResult {
  phone: string;
  otp: string;
  expiresIn: number;
}
