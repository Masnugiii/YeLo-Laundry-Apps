"use client";

import { useState } from "react";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { SettingsSectionShell } from "@/components/settings/settings-section-shell";
import { useToast } from "@/components/ui/toast";
import {
  useBackupSettings,
  useUpdateBackupSettings,
} from "@/hooks/use-settings-config";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import type { BackupSettings } from "@/types/settings-config";

export default function BackupSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const query = useBackupSettings();
  const update = useUpdateBackupSettings();
  const [draft, setDraft] = useState<BackupSettings | null>(null);

  const form = draft ?? query.data ?? null;

  function updateField<K extends keyof BackupSettings>(
    key: K,
    value: BackupSettings[K],
  ) {
    setDraft((current) => ({ ...(current ?? form!), [key]: value }));
  }

  async function handleSave() {
    if (!form) return;
    try {
      await update.mutateAsync(form);
      setDraft(null);
      toast.success("Backup settings saved.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to save backup settings."));
    }
  }

  return (
    <SettingsSectionShell
      title="Backup Configuration"
      description="Schedule and retention settings (no backup jobs are executed)."
      isLoading={query.isLoading}
      isError={query.isError}
      error={query.error}
      onRetry={() => query.refetch()}
      onSave={form ? handleSave : undefined}
      isSaving={update.isPending}
    >
      {form ? (
        <Card className="grid gap-4 md:grid-cols-2">
          <Field label="Enabled">
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={form.enabled}
                disabled={!canEdit}
                onChange={(e) => updateField("enabled", e.target.checked)}
              />
              Backup configuration enabled
            </label>
          </Field>
          <Field label="Schedule">
            <select
              className="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm disabled:bg-slate-50"
              value={form.schedule}
              disabled={!canEdit}
              onChange={(e) =>
                updateField(
                  "schedule",
                  e.target.value as BackupSettings["schedule"],
                )
              }
            >
              <option value="daily">daily</option>
              <option value="weekly">weekly</option>
              <option value="monthly">monthly</option>
            </select>
          </Field>
          <Field label="Retention (days)">
            <Input
              type="number"
              value={form.retentionDays}
              disabled={!canEdit}
              onChange={(e) =>
                updateField("retentionDays", Number(e.target.value))
              }
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
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <label className="block space-y-1">
      <CardTitle className="text-sm">{label}</CardTitle>
      {children}
    </label>
  );
}
