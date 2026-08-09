"use client";

import { useState } from "react";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { SettingsSectionShell } from "@/components/settings/settings-section-shell";
import { useToast } from "@/components/ui/toast";
import {
  useNotificationSettings,
  useUpdateNotificationSettings,
} from "@/hooks/use-settings-config";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import type {
  NotificationSettings,
  NotificationTemplateConfig,
} from "@/types/settings-config";

const TOGGLE_LABELS: Record<keyof NotificationSettings["settings"], string> = {
  notify_new_order: "New order",
  notify_payment: "Payment",
  notify_ironing_finished: "Ironing finished",
  notify_pickup_delivery: "Pickup & delivery",
  notify_wallet: "Wallet",
};

export default function NotificationsSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const query = useNotificationSettings();
  const update = useUpdateNotificationSettings();
  const [draft, setDraft] = useState<NotificationSettings | null>(null);

  const form = draft ?? query.data ?? null;

  async function handleSave() {
    if (!form) return;
    try {
      await update.mutateAsync({
        settings: form.settings,
        templates: form.templates.map((template) => ({
          id: template.id,
          title: template.title,
          body: template.body,
          isActive: template.isActive,
        })),
      });
      setDraft(null);
      toast.success("Notification settings saved.");
    } catch (error) {
      toast.error(
        getErrorMessage(error, "Failed to save notification settings."),
      );
    }
  }

  function updateToggle(
    key: keyof NotificationSettings["settings"],
    value: boolean,
  ) {
    setDraft((current) => {
      const base = current ?? form!;
      return {
        ...base,
        settings: { ...base.settings, [key]: value },
      };
    });
  }

  function updateTemplate(
    id: string,
    patch: Partial<NotificationTemplateConfig>,
  ) {
    setDraft((current) => {
      const base = current ?? form!;
      return {
        ...base,
        templates: base.templates.map((template) =>
          template.id === id ? { ...template, ...patch } : template,
        ),
      };
    });
  }

  return (
    <SettingsSectionShell
      title="Notification Configuration"
      description="Outlet notification toggles and message templates."
      isLoading={query.isLoading}
      isError={query.isError}
      error={query.error}
      onRetry={() => query.refetch()}
      onSave={form ? handleSave : undefined}
      isSaving={update.isPending}
    >
      {form ? (
        <div className="space-y-6">
          <Card className="space-y-3">
            <CardTitle>Outlet toggles</CardTitle>
            {(Object.keys(TOGGLE_LABELS) as Array<
              keyof NotificationSettings["settings"]
            >).map((key) => (
              <label key={key} className="flex items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  checked={form.settings[key]}
                  disabled={!canEdit}
                  onChange={(e) => updateToggle(key, e.target.checked)}
                />
                {TOGGLE_LABELS[key]}
              </label>
            ))}
          </Card>

          <Card className="space-y-4">
            <CardTitle>Templates</CardTitle>
            {form.templates.length === 0 ? (
              <p className="text-sm text-slate-500">No templates configured.</p>
            ) : (
              form.templates.map((template) => (
                <div
                  key={template.id}
                  className="rounded-lg border border-slate-200 p-4 space-y-3"
                >
                  <div className="flex items-center justify-between gap-4">
                    <p className="text-sm font-medium">{template.code}</p>
                    <label className="flex items-center gap-2 text-sm">
                      <input
                        type="checkbox"
                        checked={template.isActive}
                        disabled={!canEdit}
                        onChange={(e) =>
                          updateTemplate(template.id, {
                            isActive: e.target.checked,
                          })
                        }
                      />
                      Active
                    </label>
                  </div>
                  <Input
                    value={template.title}
                    disabled={!canEdit}
                    onChange={(e) =>
                      updateTemplate(template.id, { title: e.target.value })
                    }
                  />
                  <textarea
                    className="min-h-20 w-full rounded-lg border border-slate-200 px-3 py-2 text-sm disabled:bg-slate-50"
                    value={template.body}
                    disabled={!canEdit}
                    onChange={(e) =>
                      updateTemplate(template.id, { body: e.target.value })
                    }
                  />
                </div>
              ))
            )}
          </Card>
        </div>
      ) : null}
    </SettingsSectionShell>
  );
}
