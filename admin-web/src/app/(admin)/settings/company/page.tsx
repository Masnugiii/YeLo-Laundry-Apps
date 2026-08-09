"use client";

import { useState } from "react";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { SettingsSectionShell } from "@/components/settings/settings-section-shell";
import { useToast } from "@/components/ui/toast";
import {
  useCompanySettings,
  useUpdateCompanySettings,
} from "@/hooks/use-settings-config";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import type { CompanySettings } from "@/types/settings-config";

export default function CompanySettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const query = useCompanySettings();
  const update = useUpdateCompanySettings();
  const [draft, setDraft] = useState<CompanySettings | null>(null);

  const form = draft ?? query.data ?? null;

  function updateField<K extends keyof CompanySettings>(
    key: K,
    value: CompanySettings[K],
  ) {
    setDraft((current) => ({ ...(current ?? form!), [key]: value }));
  }

  async function handleSave() {
    if (!form) return;
    try {
      await update.mutateAsync({
        companyName: form.companyName,
        phone: form.phone,
        email: form.email,
        address: form.address,
        logoUrl: form.logoUrl,
        businessHours: form.businessHours,
        timezone: form.timezone,
        currency: form.currency,
        taxRate: form.taxRate,
      });
      setDraft(null);
      toast.success("Company settings saved.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to save company settings."));
    }
  }

  return (
    <SettingsSectionShell
      title="Company Profile"
      description="Outlet profile, timezone, currency, and tax settings."
      isLoading={query.isLoading}
      isError={query.isError}
      error={query.error}
      onRetry={() => query.refetch()}
      onSave={form ? handleSave : undefined}
      isSaving={update.isPending}
    >
      {form ? (
        <Card className="grid gap-4 md:grid-cols-2">
          <Field label="Company name">
            <Input
              value={form.companyName}
              disabled={!canEdit}
              onChange={(e) => updateField("companyName", e.target.value)}
            />
          </Field>
          <Field label="Phone">
            <Input
              value={form.phone ?? ""}
              disabled={!canEdit}
              onChange={(e) => updateField("phone", e.target.value || null)}
            />
          </Field>
          <Field label="Email">
            <Input
              value={form.email ?? ""}
              disabled={!canEdit}
              onChange={(e) => updateField("email", e.target.value || null)}
            />
          </Field>
          <Field label="Business hours">
            <Input
              value={form.businessHours ?? ""}
              disabled={!canEdit}
              onChange={(e) =>
                updateField("businessHours", e.target.value || null)
              }
            />
          </Field>
          <Field label="Timezone">
            <Input
              value={form.timezone ?? ""}
              disabled={!canEdit}
              onChange={(e) => updateField("timezone", e.target.value || null)}
            />
          </Field>
          <Field label="Currency">
            <Input
              value={form.currency ?? ""}
              disabled={!canEdit}
              onChange={(e) => updateField("currency", e.target.value || null)}
            />
          </Field>
          <Field label="Tax rate (%)">
            <Input
              type="number"
              value={form.taxRate ?? 0}
              disabled={!canEdit}
              onChange={(e) =>
                updateField("taxRate", Number(e.target.value))
              }
            />
          </Field>
          <Field label="Logo URL" className="md:col-span-2">
            <Input
              value={form.logoUrl ?? ""}
              disabled={!canEdit}
              onChange={(e) => updateField("logoUrl", e.target.value || null)}
            />
          </Field>
          <Field label="Address" className="md:col-span-2">
            <textarea
              className="min-h-24 w-full rounded-lg border border-slate-200 px-3 py-2 text-sm disabled:bg-slate-50"
              value={form.address ?? ""}
              disabled={!canEdit}
              onChange={(e) => updateField("address", e.target.value || null)}
            />
          </Field>
        </Card>
      ) : null}
    </SettingsSectionShell>
  );
}

function Field({
  label,
  children,
  className,
}: {
  label: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <label className={`block space-y-1 ${className ?? ""}`}>
      <CardTitle className="text-sm">{label}</CardTitle>
      {children}
    </label>
  );
}
