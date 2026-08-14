"use client";

import { useState } from "react";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { SettingsSectionShell } from "@/components/settings/settings-section-shell";
import { useToast } from "@/components/ui/toast";
import {
  usePaymentSettings,
  useUpdatePaymentSettings,
} from "@/hooks/use-settings-config";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import type { PaymentSettings } from "@/types/settings-config";

export default function PaymentSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const query = usePaymentSettings();
  const update = useUpdatePaymentSettings();
  const [draft, setDraft] = useState<PaymentSettings | null>(null);

  const form = draft ?? query.data ?? null;

  function updateQris<K extends keyof PaymentSettings["qris"]>(
    key: K,
    value: PaymentSettings["qris"][K],
  ) {
    setDraft((current) => ({
      ...(current ?? form!),
      qris: { ...(current ?? form!).qris, [key]: value },
    }));
  }

  function updateBank<K extends keyof PaymentSettings["bankTransfer"]>(
    key: K,
    value: PaymentSettings["bankTransfer"][K],
  ) {
    setDraft((current) => ({
      ...(current ?? form!),
      bankTransfer: { ...(current ?? form!).bankTransfer, [key]: value },
    }));
  }

  async function handleSave() {
    if (!form) return;
    try {
      await update.mutateAsync({
        qris: form.qris,
        bankTransfer: form.bankTransfer,
      });
      setDraft(null);
      toast.success("Payment settings saved.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to save payment settings."));
    }
  }

  return (
    <SettingsSectionShell
      title="Payment Configuration"
      description="QRIS and bank transfer settings shown in the Customer App checkout."
      isLoading={query.isLoading}
      isError={query.isError}
      error={query.error}
      onRetry={() => query.refetch()}
      onSave={form && canEdit ? handleSave : undefined}
      isSaving={update.isPending}
    >
      {form ? (
        <div className="space-y-6">
          <Card className="space-y-4">
            <CardTitle>QRIS</CardTitle>
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={form.qris.isActive}
                disabled={!canEdit}
                onChange={(e) => updateQris("isActive", e.target.checked)}
              />
              QRIS aktif
            </label>
            <Field label="QR image URL">
              <Input
                value={form.qris.qrImageUrl ?? ""}
                disabled={!canEdit}
                placeholder="https://..."
                onChange={(e) =>
                  updateQris("qrImageUrl", e.target.value || null)
                }
              />
            </Field>
            <Field label="QR payload (EMV string)">
              <textarea
                className="min-h-24 w-full rounded-md border border-slate-200 px-3 py-2 text-sm"
                value={form.qris.qrPayload ?? ""}
                disabled={!canEdit}
                onChange={(e) =>
                  updateQris("qrPayload", e.target.value || null)
                }
              />
            </Field>
            <Field label="Instruksi pembayaran">
              <textarea
                className="min-h-20 w-full rounded-md border border-slate-200 px-3 py-2 text-sm"
                value={form.qris.instructions}
                disabled={!canEdit}
                onChange={(e) => updateQris("instructions", e.target.value)}
              />
            </Field>
          </Card>

          <Card className="space-y-4">
            <CardTitle>Transfer Bank</CardTitle>
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={form.bankTransfer.isActive}
                disabled={!canEdit}
                onChange={(e) =>
                  updateBank("isActive", e.target.checked)
                }
              />
              Transfer bank aktif
            </label>
            <Field label="Nama bank">
              <Input
                value={form.bankTransfer.bankName}
                disabled={!canEdit}
                onChange={(e) => updateBank("bankName", e.target.value)}
              />
            </Field>
            <Field label="Nomor rekening">
              <Input
                value={form.bankTransfer.accountNumber}
                disabled={!canEdit}
                onChange={(e) => updateBank("accountNumber", e.target.value)}
              />
            </Field>
            <Field label="Nama pemilik rekening">
              <Input
                value={form.bankTransfer.accountHolder}
                disabled={!canEdit}
                onChange={(e) => updateBank("accountHolder", e.target.value)}
              />
            </Field>
            <Field label="Instruksi pembayaran">
              <textarea
                className="min-h-20 w-full rounded-md border border-slate-200 px-3 py-2 text-sm"
                value={form.bankTransfer.instructions}
                disabled={!canEdit}
                onChange={(e) => updateBank("instructions", e.target.value)}
              />
            </Field>
          </Card>
        </div>
      ) : null}
    </SettingsSectionShell>
  );
}

function Field({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <label className="block space-y-1 text-sm">
      <span className="font-medium text-slate-700">{label}</span>
      {children}
    </label>
  );
}
