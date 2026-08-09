"use client";

import { useState } from "react";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { SettingsSectionShell } from "@/components/settings/settings-section-shell";
import { useToast } from "@/components/ui/toast";
import {
  useDocumentRules,
  useUpdateDocumentRules,
} from "@/hooks/use-settings-config";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import type { DocumentRules } from "@/types/settings-config";

const MIME_OPTIONS = [
  "image/jpeg",
  "image/png",
  "application/pdf",
];

export default function DocumentsSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const query = useDocumentRules();
  const update = useUpdateDocumentRules();
  const [draft, setDraft] = useState<DocumentRules | null>(null);

  const form = draft ?? query.data ?? null;

  function updateField<K extends keyof DocumentRules>(
    key: K,
    value: DocumentRules[K],
  ) {
    setDraft((current) => ({ ...(current ?? form!), [key]: value }));
  }

  async function handleSave() {
    if (!form) return;
    try {
      await update.mutateAsync(form);
      setDraft(null);
      toast.success("Document rules saved.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to save document rules."));
    }
  }

  return (
    <SettingsSectionShell
      title="Document Rules"
      description="Upload limits and allowed file types (configuration only)."
      isLoading={query.isLoading}
      isError={query.isError}
      error={query.error}
      onRetry={() => query.refetch()}
      onSave={form ? handleSave : undefined}
      isSaving={update.isPending}
    >
      {form ? (
        <Card className="grid gap-4 md:grid-cols-2">
          <Field label="Max file size (bytes)">
            <Input
              type="number"
              value={form.maxFileSizeBytes}
              disabled={!canEdit}
              onChange={(e) =>
                updateField("maxFileSizeBytes", Number(e.target.value))
              }
            />
            <p className="text-xs text-slate-500">
              Default: 10 MB ({10 * 1024 * 1024} bytes)
            </p>
          </Field>
          <Field label="Compression mode">
            <select
              className="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm disabled:bg-slate-50"
              value={form.compressionMode}
              disabled={!canEdit}
              onChange={(e) =>
                updateField(
                  "compressionMode",
                  e.target.value as DocumentRules["compressionMode"],
                )
              }
            >
              <option value="original">original</option>
              <option value="compress">compress</option>
            </select>
          </Field>
          <Field label="OCR enabled">
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={form.ocrEnabled}
                disabled={!canEdit}
                onChange={(e) => updateField("ocrEnabled", e.target.checked)}
              />
              Enable OCR (configuration flag only)
            </label>
          </Field>
          <Field label="Allowed MIME types" className="md:col-span-2">
            <div className="flex flex-wrap gap-3">
              {MIME_OPTIONS.map((mime) => (
                <label key={mime} className="flex items-center gap-2 text-sm">
                  <input
                    type="checkbox"
                    checked={form.allowedMimeTypes.includes(mime)}
                    disabled={!canEdit}
                    onChange={(e) => {
                      const next = e.target.checked
                        ? [...form.allowedMimeTypes, mime]
                        : form.allowedMimeTypes.filter((item) => item !== mime);
                      updateField("allowedMimeTypes", next);
                    }}
                  />
                  {mime}
                </label>
              ))}
            </div>
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
