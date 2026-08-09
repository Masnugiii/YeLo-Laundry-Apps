"use client";

import { useState } from "react";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { SettingsSectionShell } from "@/components/settings/settings-section-shell";
import { useToast } from "@/components/ui/toast";
import {
  useAttendanceSettings,
  useUpdateAttendanceSettings,
} from "@/hooks/use-settings-config";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import type { AttendanceSettings } from "@/types/settings-config";

export default function AttendanceSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const query = useAttendanceSettings();
  const update = useUpdateAttendanceSettings();
  const [draft, setDraft] = useState<AttendanceSettings | null>(null);

  const form = draft ?? query.data ?? null;

  function updateField<K extends keyof AttendanceSettings>(
    key: K,
    value: AttendanceSettings[K],
  ) {
    setDraft((current) => ({ ...(current ?? form!), [key]: value }));
  }

  async function handleSave() {
    if (!form) return;
    try {
      await update.mutateAsync({
        workStartTime: form.workStartTime,
        workEndTime: form.workEndTime,
        lateToleranceMinutes: form.lateToleranceMinutes,
        overtimeEnabled: form.overtimeEnabled,
        gps: form.gps,
      });
      setDraft(null);
      toast.success("Attendance settings saved.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to save attendance settings."));
    }
  }

  return (
    <SettingsSectionShell
      title="Attendance Configuration"
      description="Default work hours, late tolerance, overtime, and GPS office radius."
      isLoading={query.isLoading}
      isError={query.isError}
      error={query.error}
      onRetry={() => query.refetch()}
      onSave={form ? handleSave : undefined}
      isSaving={update.isPending}
    >
      {form ? (
        <div className="space-y-4">
          <Card className="grid gap-4 md:grid-cols-2">
            <Field label="Work start (HH:mm)">
              <Input
                value={form.workStartTime}
                disabled={!canEdit}
                onChange={(e) => updateField("workStartTime", e.target.value)}
              />
            </Field>
            <Field label="Work end (HH:mm)">
              <Input
                value={form.workEndTime}
                disabled={!canEdit}
                onChange={(e) => updateField("workEndTime", e.target.value)}
              />
            </Field>
            <Field label="Late tolerance (minutes)">
              <Input
                type="number"
                value={form.lateToleranceMinutes}
                disabled={!canEdit}
                onChange={(e) =>
                  updateField("lateToleranceMinutes", Number(e.target.value))
                }
              />
            </Field>
            <Field label="Overtime enabled">
              <label className="flex items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  checked={form.overtimeEnabled}
                  disabled={!canEdit}
                  onChange={(e) =>
                    updateField("overtimeEnabled", e.target.checked)
                  }
                />
                Enable overtime tracking
              </label>
            </Field>
            <Field label="Active shifts (read-only)" className="md:col-span-2">
              <Input value={String(form.shiftCount)} disabled readOnly />
            </Field>
          </Card>

          <Card className="grid gap-4 md:grid-cols-3">
            <CardTitle className="md:col-span-3 text-base">GPS Office</CardTitle>
            <Field label="Latitude">
              <Input
                type="number"
                value={form.gps?.officeLatitude ?? ""}
                disabled={!canEdit}
                onChange={(e) =>
                  updateField("gps", {
                    officeLatitude: Number(e.target.value),
                    officeLongitude: form.gps?.officeLongitude ?? 0,
                    officeRadiusMeters: form.gps?.officeRadiusMeters ?? 100,
                  })
                }
              />
            </Field>
            <Field label="Longitude">
              <Input
                type="number"
                value={form.gps?.officeLongitude ?? ""}
                disabled={!canEdit}
                onChange={(e) =>
                  updateField("gps", {
                    officeLatitude: form.gps?.officeLatitude ?? 0,
                    officeLongitude: Number(e.target.value),
                    officeRadiusMeters: form.gps?.officeRadiusMeters ?? 100,
                  })
                }
              />
            </Field>
            <Field label="Radius (meters)">
              <Input
                type="number"
                value={form.gps?.officeRadiusMeters ?? ""}
                disabled={!canEdit}
                onChange={(e) =>
                  updateField("gps", {
                    officeLatitude: form.gps?.officeLatitude ?? 0,
                    officeLongitude: form.gps?.officeLongitude ?? 0,
                    officeRadiusMeters: Number(e.target.value),
                  })
                }
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
  className,
}: {
  label: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <label className={`block space-y-1 ${className ?? ""}`}>
      <span className="text-sm font-medium text-slate-700">{label}</span>
      {children}
    </label>
  );
}
