"use client";

import { useState } from "react";
import Link from "next/link";
import {
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import {
  useCreateVoucher,
  useLoyaltySettings,
  useUpdateLoyaltySettings,
  useVouchers,
} from "@/hooks/use-loyalty";
import { getErrorMessage } from "@/lib/errors";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { LoyaltySettings } from "@/types/loyalty";

export default function LoyaltySettingsPage() {
  const toast = useToast();
  const settingsQuery = useLoyaltySettings();
  const vouchersQuery = useVouchers({ page: 1, limit: 20 });
  const updateSettings = useUpdateLoyaltySettings();
  const createVoucher = useCreateVoucher();
  const [draft, setDraft] = useState<LoyaltySettings | null>(null);
  const [voucherCode, setVoucherCode] = useState("");
  const [voucherName, setVoucherName] = useState("");
  const [voucherDiscount, setVoucherDiscount] = useState(10);

  const form = draft ?? settingsQuery.data ?? null;

  if (settingsQuery.isLoading) return <FinanceListSkeleton />;
  if (settingsQuery.isError || !form) {
    return (
      <QueryErrorState
        title="Failed to load loyalty settings"
        message={getErrorMessage(settingsQuery.error, "Unable to load settings.")}
        onRetry={() => settingsQuery.refetch()}
      />
    );
  }

  function updateField<K extends keyof LoyaltySettings>(key: K, value: LoyaltySettings[K]) {
    setDraft((current) => {
      const base = current ?? form;
      return { ...base, [key]: value } as LoyaltySettings;
    });
  }

  async function handleSave() {
    const payload = draft ?? form;
    if (!payload) return;
    try {
      await updateSettings.mutateAsync(payload);
      setDraft(null);
      toast.success("Loyalty settings saved.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to save settings."));
    }
  }

  async function handleCreateVoucher() {
    const today = new Date();
    const end = new Date();
    end.setMonth(end.getMonth() + 1);
    try {
      await createVoucher.mutateAsync({
        code: voucherCode,
        name: voucherName,
        discountType: "PERCENTAGE",
        discountValue: voucherDiscount,
        startDate: today.toISOString(),
        endDate: end.toISOString(),
        usageLimit: 100,
        minimumTransaction: 0,
      });
      toast.success("Voucher created.");
      setVoucherCode("");
      setVoucherName("");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to create voucher."));
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <Link href="/operations/customers/wallet" className="text-sm text-blue-600 hover:underline">
            ← Back to Wallet
          </Link>
          <h2 className="mt-2 text-xl font-semibold">Loyalty Configuration</h2>
          <p className="text-sm text-slate-500">
            Configure reward points, membership tiers, cashback, and wallet rules.
          </p>
        </div>
        <Button onClick={handleSave} disabled={updateSettings.isPending}>
          Save Settings
        </Button>
      </div>

      <Card className="space-y-4 p-6">
        <CardTitle>Point Rules</CardTitle>
        <div className="grid gap-4 md:grid-cols-3">
          <label className="space-y-1 text-sm">
            <span>Point Per Rupiah Unit</span>
            <Input
              type="number"
              value={form.pointPerRupiah}
              onChange={(e) => updateField("pointPerRupiah", Number(e.target.value))}
            />
          </label>
          <label className="space-y-1 text-sm">
            <span>Rupiah Per Point</span>
            <Input
              type="number"
              value={form.rupiahPerPoint}
              onChange={(e) => updateField("rupiahPerPoint", Number(e.target.value))}
            />
          </label>
          <label className="space-y-1 text-sm">
            <span>Point Expiration (days)</span>
            <Input
              type="number"
              value={form.pointExpirationDays}
              onChange={(e) => updateField("pointExpirationDays", Number(e.target.value))}
            />
          </label>
        </div>
      </Card>

      <Card className="space-y-4 p-6">
        <CardTitle>Membership Levels</CardTitle>
        <div className="space-y-3">
          {form.membershipLevels.map((level, index) => (
            <div key={level.code} className="grid gap-3 rounded-lg border p-4 md:grid-cols-4">
              <Input
                value={level.name}
                onChange={(e) => {
                  const levels = [...form.membershipLevels];
                  levels[index] = { ...level, name: e.target.value };
                  updateField("membershipLevels", levels);
                }}
              />
              <Input
                type="number"
                value={level.minPoints}
                onChange={(e) => {
                  const levels = [...form.membershipLevels];
                  levels[index] = { ...level, minPoints: Number(e.target.value) };
                  updateField("membershipLevels", levels);
                }}
              />
              <Input
                className="md:col-span-2"
                value={level.benefits.join(", ")}
                onChange={(e) => {
                  const levels = [...form.membershipLevels];
                  levels[index] = {
                    ...level,
                    benefits: e.target.value.split(",").map((b) => b.trim()).filter(Boolean),
                  };
                  updateField("membershipLevels", levels);
                }}
                placeholder="Benefits (comma separated)"
              />
            </div>
          ))}
        </div>
      </Card>

      <Card className="space-y-4 p-6">
        <CardTitle>Cashback Rules</CardTitle>
        <div className="grid gap-4 md:grid-cols-2">
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={form.cashback.enabled}
              onChange={(e) =>
                updateField("cashback", { ...form.cashback, enabled: e.target.checked })
              }
            />
            Enable Cashback
          </label>
          <Input
            type="number"
            value={form.cashback.value}
            onChange={(e) =>
              updateField("cashback", { ...form.cashback, value: Number(e.target.value) })
            }
            placeholder="Cashback %"
          />
          <Input
            type="number"
            value={form.cashback.maxAmount}
            onChange={(e) =>
              updateField("cashback", {
                ...form.cashback,
                maxAmount: Number(e.target.value),
              })
            }
            placeholder="Max Cashback"
          />
          <Input
            type="number"
            value={form.wallet.minTopup}
            onChange={(e) =>
              updateField("wallet", { ...form.wallet, minTopup: Number(e.target.value) })
            }
            placeholder="Min Top Up"
          />
        </div>
      </Card>

      <Card className="space-y-4 p-6">
        <CardTitle>Vouchers</CardTitle>
        <div className="grid gap-3 md:grid-cols-4">
          <Input placeholder="Code" value={voucherCode} onChange={(e) => setVoucherCode(e.target.value)} />
          <Input placeholder="Name" value={voucherName} onChange={(e) => setVoucherName(e.target.value)} />
          <Input
            type="number"
            placeholder="Discount %"
            value={voucherDiscount}
            onChange={(e) => setVoucherDiscount(Number(e.target.value))}
          />
          <Button onClick={handleCreateVoucher} disabled={!voucherCode || !voucherName}>
            Create Voucher
          </Button>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="border-b text-left text-slate-500">
                <th className="px-3 py-2">Code</th>
                <th className="px-3 py-2">Name</th>
                <th className="px-3 py-2">Discount</th>
                <th className="px-3 py-2">Period</th>
                <th className="px-3 py-2">Usage</th>
                <th className="px-3 py-2">Status</th>
              </tr>
            </thead>
            <tbody>
              {(vouchersQuery.data?.items ?? []).map((voucher) => (
                <tr key={voucher.id} className="border-b">
                  <td className="px-3 py-2">{voucher.code}</td>
                  <td className="px-3 py-2">{voucher.name}</td>
                  <td className="px-3 py-2">
                    {voucher.discountType === "PERCENTAGE"
                      ? `${voucher.discountValue}%`
                      : formatCurrency(voucher.discountValue)}
                  </td>
                  <td className="px-3 py-2">
                    {formatDate(voucher.startDate)} – {formatDate(voucher.endDate)}
                  </td>
                  <td className="px-3 py-2">
                    {voucher.usageCount}/{voucher.usageLimit || "∞"}
                  </td>
                  <td className="px-3 py-2">{voucher.status}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
