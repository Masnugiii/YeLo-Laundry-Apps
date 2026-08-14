"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { SettingsSectionShell } from "@/components/settings/settings-section-shell";
import { useToast } from "@/components/ui/toast";
import {
  useCreateVoucher,
  useUpdateVoucher,
  useVouchers,
} from "@/hooks/use-loyalty";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { LoyaltyVoucher } from "@/types/loyalty";

type PromoDraft = {
  id?: string;
  code: string;
  name: string;
  description: string;
  discountPercent: number;
  startDate: string;
  endDate: string;
  minimumTransaction: number;
  maxDiscount: number | "";
  usageLimit: number;
  status: LoyaltyVoucher["status"];
};

const emptyDraft = (): PromoDraft => {
  const today = new Date();
  const end = new Date();
  end.setMonth(end.getMonth() + 1);
  return {
    code: "",
    name: "",
    description: "",
    discountPercent: 10,
    startDate: today.toISOString().slice(0, 10),
    endDate: end.toISOString().slice(0, 10),
    minimumTransaction: 0,
    maxDiscount: "",
    usageLimit: 0,
    status: "ACTIVE",
  };
};

function toDraft(voucher: LoyaltyVoucher): PromoDraft {
  return {
    id: voucher.id,
    code: voucher.code,
    name: voucher.name,
    description: voucher.description ?? "",
    discountPercent:
      voucher.discountPercent ??
      (voucher.discountType === "PERCENTAGE" ? voucher.discountValue : 0),
    startDate: voucher.startDate.slice(0, 10),
    endDate: voucher.endDate.slice(0, 10),
    minimumTransaction: voucher.minimumTransaction,
    maxDiscount: voucher.maxDiscount ?? "",
    usageLimit: voucher.usageLimit,
    status: voucher.status,
  };
}

export default function PromoSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const vouchersQuery = useVouchers({ page: 1, limit: 50 });
  const createVoucher = useCreateVoucher();
  const updateVoucher = useUpdateVoucher();
  const [draft, setDraft] = useState<PromoDraft>(emptyDraft);
  const [editingId, setEditingId] = useState<string | null>(null);

  function updateField<K extends keyof PromoDraft>(key: K, value: PromoDraft[K]) {
    setDraft((current) => ({ ...current, [key]: value }));
  }

  function startEdit(voucher: LoyaltyVoucher) {
    setEditingId(voucher.id);
    setDraft(toDraft(voucher));
  }

  function resetForm() {
    setEditingId(null);
    setDraft(emptyDraft());
  }

  async function handleSave() {
    if (!draft.code.trim() || !draft.name.trim()) {
      toast.error("Kode dan nama promo wajib diisi.");
      return;
    }

    const payload = {
      code: draft.code.trim(),
      name: draft.name.trim(),
      description: draft.description.trim() || undefined,
      discountType: "PERCENTAGE" as const,
      discountPercent: draft.discountPercent,
      startDate: new Date(`${draft.startDate}T00:00:00`).toISOString(),
      endDate: new Date(`${draft.endDate}T23:59:59`).toISOString(),
      minimumTransaction: draft.minimumTransaction,
      maxDiscount:
        draft.maxDiscount === "" ? undefined : Number(draft.maxDiscount),
      usageLimit: draft.usageLimit,
      status: draft.status,
    };

    try {
      if (editingId) {
        await updateVoucher.mutateAsync({ id: editingId, input: payload });
        toast.success("Promo diperbarui.");
      } else {
        await createVoucher.mutateAsync(payload);
        toast.success("Promo dibuat.");
      }
      resetForm();
    } catch (error) {
      toast.error(getErrorMessage(error, "Gagal menyimpan promo."));
    }
  }

  return (
    <SettingsSectionShell
      title="Promo Configuration"
      description="Kelola promo persentase yang ditampilkan di Customer App."
      isLoading={vouchersQuery.isLoading}
      isError={vouchersQuery.isError}
      error={vouchersQuery.error}
      onRetry={() => vouchersQuery.refetch()}
    >
      <div className="space-y-6">
        <Card className="space-y-4">
          <CardTitle>{editingId ? "Edit Promo" : "Tambah Promo"}</CardTitle>
          <div className="grid gap-4 md:grid-cols-2">
            <label className="space-y-1 text-sm">
              <span>Kode Voucher</span>
              <Input
                value={draft.code}
                disabled={!canEdit}
                onChange={(e) => updateField("code", e.target.value.toUpperCase())}
                placeholder="YELO20"
              />
            </label>
            <label className="space-y-1 text-sm">
              <span>Nama Promo</span>
              <Input
                value={draft.name}
                disabled={!canEdit}
                onChange={(e) => updateField("name", e.target.value)}
                placeholder="Promo Laundry"
              />
            </label>
            <label className="space-y-1 text-sm md:col-span-2">
              <span>Deskripsi</span>
              <Input
                value={draft.description}
                disabled={!canEdit}
                onChange={(e) => updateField("description", e.target.value)}
                placeholder="Hemat untuk laundry kamu"
              />
            </label>
            <label className="space-y-1 text-sm">
              <span>Diskon (%)</span>
              <Input
                type="number"
                min={0}
                step={1}
                value={draft.discountPercent}
                disabled={!canEdit}
                onChange={(e) =>
                  updateField("discountPercent", Number(e.target.value))
                }
              />
            </label>
            <label className="space-y-1 text-sm">
              <span>Status</span>
              <select
                className="h-10 w-full rounded-md border border-slate-200 px-3 text-sm"
                value={draft.status}
                disabled={!canEdit}
                onChange={(e) =>
                  updateField("status", e.target.value as LoyaltyVoucher["status"])
                }
              >
                <option value="ACTIVE">ACTIVE</option>
                <option value="INACTIVE">INACTIVE</option>
              </select>
            </label>
            <label className="space-y-1 text-sm">
              <span>Periode Mulai</span>
              <Input
                type="date"
                value={draft.startDate}
                disabled={!canEdit}
                onChange={(e) => updateField("startDate", e.target.value)}
              />
            </label>
            <label className="space-y-1 text-sm">
              <span>Periode Berakhir</span>
              <Input
                type="date"
                value={draft.endDate}
                disabled={!canEdit}
                onChange={(e) => updateField("endDate", e.target.value)}
              />
            </label>
            <label className="space-y-1 text-sm">
              <span>Minimum Transaksi</span>
              <Input
                type="number"
                min={0}
                value={draft.minimumTransaction}
                disabled={!canEdit}
                onChange={(e) =>
                  updateField("minimumTransaction", Number(e.target.value))
                }
              />
            </label>
            <label className="space-y-1 text-sm">
              <span>Maksimum Diskon (opsional)</span>
              <Input
                type="number"
                min={0}
                value={draft.maxDiscount}
                disabled={!canEdit}
                onChange={(e) =>
                  updateField(
                    "maxDiscount",
                    e.target.value === "" ? "" : Number(e.target.value),
                  )
                }
              />
            </label>
            <label className="space-y-1 text-sm">
              <span>Kuota Penggunaan (0 = unlimited)</span>
              <Input
                type="number"
                min={0}
                value={draft.usageLimit}
                disabled={!canEdit}
                onChange={(e) => updateField("usageLimit", Number(e.target.value))}
              />
            </label>
          </div>
          {canEdit ? (
            <div className="flex flex-wrap gap-2">
              <Button
                onClick={handleSave}
                disabled={createVoucher.isPending || updateVoucher.isPending}
              >
                {editingId ? "Simpan Perubahan" : "Buat Promo"}
              </Button>
              {editingId ? (
                <Button variant="outline" onClick={resetForm}>
                  Batal
                </Button>
              ) : null}
            </div>
          ) : null}
        </Card>

        <Card className="space-y-4">
          <CardTitle>Daftar Promo</CardTitle>
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead>
                <tr className="border-b text-left text-slate-500">
                  <th className="px-3 py-2">Badge</th>
                  <th className="px-3 py-2">Nama</th>
                  <th className="px-3 py-2">Periode</th>
                  <th className="px-3 py-2">Min. Transaksi</th>
                  <th className="px-3 py-2">Maks. Diskon</th>
                  <th className="px-3 py-2">Status</th>
                  <th className="px-3 py-2" />
                </tr>
              </thead>
              <tbody>
                {(vouchersQuery.data?.items ?? []).map((voucher) => {
                  const percent =
                    voucher.discountPercent ??
                    (voucher.discountType === "PERCENTAGE"
                      ? voucher.discountValue
                      : null);
                  return (
                    <tr key={voucher.id} className="border-b">
                      <td className="px-3 py-2">
                        {percent !== null ? (
                          <span className="inline-flex rounded-full bg-[#F8D613] px-2 py-0.5 text-xs font-semibold text-[#033B8E]">
                            {percent}%
                          </span>
                        ) : (
                          formatCurrency(voucher.discountValue)
                        )}
                      </td>
                      <td className="px-3 py-2">
                        <div className="font-medium">{voucher.name}</div>
                        <div className="text-xs text-slate-500">{voucher.code}</div>
                      </td>
                      <td className="px-3 py-2">
                        {formatDate(voucher.startDate)} – {formatDate(voucher.endDate)}
                      </td>
                      <td className="px-3 py-2">
                        {formatCurrency(voucher.minimumTransaction)}
                      </td>
                      <td className="px-3 py-2">
                        {voucher.maxDiscount
                          ? formatCurrency(voucher.maxDiscount)
                          : "—"}
                      </td>
                      <td className="px-3 py-2">{voucher.status}</td>
                      <td className="px-3 py-2">
                        {canEdit ? (
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => startEdit(voucher)}
                          >
                            Edit
                          </Button>
                        ) : null}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </Card>
      </div>
    </SettingsSectionShell>
  );
}
