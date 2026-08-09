"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { apiGet, apiPatch } from "@/lib/api";

interface CompanySettings {
  companyName: string;
  phone: string | null;
  email: string | null;
  address: string | null;
  logoUrl: string | null;
  businessHours: string | null;
  timezone: string | null;
  currency: string | null;
  taxRate: number | null;
}

export default function SettingsPage() {
  const queryClient = useQueryClient();
  const { data } = useQuery({
    queryKey: ["company-settings"],
    queryFn: () => apiGet<CompanySettings>("/admin/settings/company"),
  });

  const save = useMutation({
    mutationFn: (body: Partial<CompanySettings>) =>
      apiPatch<CompanySettings>("/admin/settings/company", body),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["company-settings"] }),
  });

  if (!data) return <p>Loading settings...</p>;

  return (
    <Card>
      <CardTitle>System Settings</CardTitle>
      <div className="mt-4 grid gap-3 md:grid-cols-2">
        {(
          [
            ["companyName", "Company Name"],
            ["phone", "Phone"],
            ["email", "Email"],
            ["address", "Address"],
            ["logoUrl", "Logo URL"],
            ["businessHours", "Business Hours"],
            ["timezone", "Timezone"],
            ["currency", "Currency"],
          ] as const
        ).map(([key, label]) => (
          <div key={key}>
            <label className="mb-1 block text-sm">{label}</label>
            <Input
              value={String(data[key] ?? "")}
              onChange={(e) => save.mutate({ [key]: e.target.value })}
            />
          </div>
        ))}
        <div>
          <label className="mb-1 block text-sm">Tax Rate (%)</label>
          <Input
            type="number"
            value={data.taxRate ?? 0}
            onChange={(e) => save.mutate({ taxRate: Number(e.target.value) })}
          />
        </div>
      </div>
      <Button className="mt-4" variant="outline" onClick={() => save.mutate(data)}>
        Save Settings
      </Button>
    </Card>
  );
}
