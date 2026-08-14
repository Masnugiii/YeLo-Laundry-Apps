"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState, useSyncExternalStore } from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import { useGenerateDevOtp } from "@/hooks/use-otp-testing";
import { isOwnerRole } from "@/lib/auth";
import { isDevToolsEnabled } from "@/lib/env";
import { getErrorMessage } from "@/lib/errors";
import type { DevGenerateOtpResult, OtpTestingPurpose } from "@/types/otp-testing";

function formatCountdown(seconds: number): string {
  const minutes = Math.floor(seconds / 60);
  const remainder = seconds % 60;
  return `${minutes}:${remainder.toString().padStart(2, "0")}`;
}

function readCanAccess(): boolean {
  return isOwnerRole() && isDevToolsEnabled();
}

function subscribeToAccess(onStoreChange: () => void) {
  window.addEventListener("storage", onStoreChange);
  return () => window.removeEventListener("storage", onStoreChange);
}

export default function OtpTestingPage() {
  const router = useRouter();
  const toast = useToast();
  const canAccess = useSyncExternalStore(
    subscribeToAccess,
    readCanAccess,
    () => false,
  );
  const generateMutation = useGenerateDevOtp();

  const [phone, setPhone] = useState("081234567890");
  const [purpose, setPurpose] = useState<OtpTestingPurpose>("login");
  const [result, setResult] = useState<DevGenerateOtpResult | null>(null);
  const [expiresAt, setExpiresAt] = useState<number | null>(null);
  const [remainingSeconds, setRemainingSeconds] = useState(0);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    if (!canAccess) {
      router.replace("/settings");
    }
  }, [canAccess, router]);

  useEffect(() => {
    if (!expiresAt) {
      setRemainingSeconds(0);
      return;
    }

    const updateRemaining = () => {
      const next = Math.max(0, Math.floor((expiresAt - Date.now()) / 1000));
      setRemainingSeconds(next);
      if (next === 0) {
        setResult(null);
      }
    };

    updateRemaining();
    const timer = window.setInterval(updateRemaining, 1000);
    return () => window.clearInterval(timer);
  }, [expiresAt]);

  const statusLabel = useMemo(() => {
    if (generateMutation.isPending) return "Generating OTP...";
    if (errorMessage) return "Error";
    if (result) return "Success";
    return "Ready";
  }, [errorMessage, generateMutation.isPending, result]);

  const handleGenerate = async () => {
    setErrorMessage(null);
    setResult(null);
    setExpiresAt(null);

    try {
      const data = await generateMutation.mutateAsync({ phone, purpose });
      setResult(data);
      setExpiresAt(Date.now() + data.expiresIn * 1000);
    } catch (error) {
      setErrorMessage(
        getErrorMessage(error, "Failed to generate development OTP."),
      );
    }
  };

  const handleCopy = async () => {
    if (!result?.otp) return;

    try {
      await navigator.clipboard.writeText(result.otp);
      toast.success("OTP copied to clipboard");
    } catch {
      toast.error("Unable to copy OTP");
    }
  };

  if (!canAccess) {
    return null;
  }

  return (
    <div className="space-y-6">
      <div>
        <Link href="/settings/development-tools" className="text-sm text-blue-600">
          ← Back to Development Tools
        </Link>
        <h2 className="mt-2 text-xl font-semibold">OTP Testing</h2>
        <p className="text-sm text-slate-500">
          Generate OTP test untuk Customer App tanpa melihat terminal backend.
        </p>
      </div>

      <div className="rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900">
        Development only — jangan digunakan untuk production.
      </div>

      <Card className="space-y-4 p-5">
        <div className="space-y-2">
          <label htmlFor="otp-phone" className="text-sm font-medium text-slate-700">
            Nomor HP
          </label>
          <Input
            id="otp-phone"
            value={phone}
            onChange={(event) => setPhone(event.target.value)}
            placeholder="081234567890"
            autoComplete="off"
          />
        </div>

        <div className="space-y-2">
          <label htmlFor="otp-purpose" className="text-sm font-medium text-slate-700">
            Purpose
          </label>
          <select
            id="otp-purpose"
            value={purpose}
            onChange={(event) =>
              setPurpose(event.target.value as OtpTestingPurpose)
            }
            className="h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-sm"
          >
            <option value="login">login</option>
            <option value="register">register</option>
          </select>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <Button onClick={handleGenerate} disabled={generateMutation.isPending}>
            {generateMutation.isPending ? "Generating..." : "Generate Test OTP"}
          </Button>
          <span className="text-sm text-slate-500">Status: {statusLabel}</span>
        </div>

        {errorMessage ? (
          <div className="rounded-md border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            {errorMessage}
          </div>
        ) : null}

        {result ? (
          <div className="rounded-md border border-emerald-200 bg-emerald-50 px-4 py-4">
            <p className="text-sm text-emerald-800">OTP berhasil dibuat untuk {result.phone}</p>
            <div className="mt-3 flex flex-wrap items-center gap-3">
              <span className="font-mono text-3xl font-semibold tracking-[0.3em] text-emerald-900">
                {result.otp}
              </span>
              <Button variant="outline" size="sm" onClick={handleCopy}>
                Copy
              </Button>
            </div>
            <p className="mt-3 text-sm text-emerald-800">
              Expires in {formatCountdown(remainingSeconds)}
            </p>
          </div>
        ) : null}
      </Card>

      <Card className="space-y-2 p-5 text-sm text-slate-600">
        <p className="font-medium text-slate-800">Cara uji di Customer App</p>
        <ol className="list-decimal space-y-1 pl-5">
          <li>Buka Customer App, masukkan nomor HP yang sama, lalu tap Kirim OTP.</li>
          <li>Kembali ke halaman ini dan tap Generate Test OTP.</li>
          <li>Masukkan OTP 6 digit di layar verifikasi Customer App.</li>
        </ol>
        <p>
          OTP diverifikasi oleh backend melalui endpoint <code>/auth/otp/verify</code> yang
          sudah ada.
        </p>
      </Card>
    </div>
  );
}
