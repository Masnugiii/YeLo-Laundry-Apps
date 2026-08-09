"use client";

import { Card, CardTitle } from "@/components/ui/card";
import { SettingsSectionShell } from "@/components/settings/settings-section-shell";
import { useDeliverySettings } from "@/hooks/use-settings-config";

export default function DeliverySettingsPage() {
  const query = useDeliverySettings();

  return (
    <SettingsSectionShell
      title="Delivery Configuration"
      description="Pickup and delivery operational configuration."
      isLoading={query.isLoading}
      isError={query.isError}
      error={query.error}
      onRetry={() => query.refetch()}
    >
      <Card className="p-6 text-center">
        <CardTitle className="text-base">Belum dikonfigurasi</CardTitle>
        <p className="mt-2 text-sm text-slate-500">
          {query.data?.message ??
            "No delivery configuration model exists in the current schema."}
        </p>
        <p className="mt-1 text-xs text-slate-400">status: not_configured</p>
      </Card>
    </SettingsSectionShell>
  );
}
