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
  useCreateRewardCatalogItem,
  useLoyaltySettings,
  useRewardCatalog,
  useUpdateLoyaltySettings,
  useUpdateRewardCatalogItem,
} from "@/hooks/use-loyalty";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import type {
  LoyaltySettings,
  RewardCatalogItem,
  RewardCatalogType,
} from "@/types/loyalty";

export default function YeloRewardsSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const settingsQuery = useLoyaltySettings();
  const catalogQuery = useRewardCatalog(true);
  const updateSettings = useUpdateLoyaltySettings();
  const createCatalogItem = useCreateRewardCatalogItem();
  const [draft, setDraft] = useState<LoyaltySettings | null>(null);
  const [editingItemId, setEditingItemId] = useState<string | null>(null);

  const form = draft ?? settingsQuery.data ?? null;

  if (settingsQuery.isLoading || catalogQuery.isLoading) {
    return <FinanceListSkeleton />;
  }

  if (settingsQuery.isError || !form) {
    return (
      <QueryErrorState
        title="Failed to load YeLo Rewards settings"
        message={getErrorMessage(settingsQuery.error, "Unable to load settings.")}
        onRetry={() => settingsQuery.refetch()}
      />
    );
  }

  function patchSettings(next: Partial<LoyaltySettings>) {
    setDraft((current) => {
      const base = current ?? form;
      if (!base) return current;
      return { ...base, ...next } as LoyaltySettings;
    });
  }

  async function handleSaveSettings() {
    const payload = draft ?? form;
    if (!payload) return;
    try {
      await updateSettings.mutateAsync(payload);
      setDraft(null);
      toast.success("YeLo Rewards settings saved.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to save settings."));
    }
  }

  const catalog = catalogQuery.data ?? [];

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <Link href="/settings" className="text-sm text-blue-600 hover:underline">
            ← Back to Settings
          </Link>
          <h2 className="mt-2 text-xl font-semibold">YeLo Rewards</h2>
          <p className="text-sm text-slate-500">
            Configure point earning, membership, cashback, and reward catalog.
            {canEdit ? "" : " View-only for Manager."}
          </p>
        </div>
        {canEdit ? (
          <Button onClick={handleSaveSettings} disabled={updateSettings.isPending}>
            Save Settings
          </Button>
        ) : null}
      </div>

      <Card className="space-y-4 p-6">
        <CardTitle>Laundry Point</CardTitle>
        <p className="text-sm text-slate-500">
          Formula: floor(amount / minimum transaction) × points per unit
        </p>
        <div className="grid gap-4 md:grid-cols-3">
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={form.laundryPoint.enabled}
              disabled={!canEdit}
              onChange={(e) =>
                patchSettings({
                  laundryPoint: { ...form.laundryPoint, enabled: e.target.checked },
                })
              }
            />
            Enabled
          </label>
          <label className="space-y-1 text-sm">
            <span>Minimum Transaction (Rp)</span>
            <Input
              type="number"
              disabled={!canEdit}
              value={form.laundryPoint.minimumTransaction}
              onChange={(e) =>
                patchSettings({
                  laundryPoint: {
                    ...form.laundryPoint,
                    minimumTransaction: Number(e.target.value),
                  },
                  rupiahPerPoint: Number(e.target.value),
                })
              }
            />
          </label>
          <label className="space-y-1 text-sm">
            <span>Points Per Unit</span>
            <Input
              type="number"
              disabled={!canEdit}
              value={form.laundryPoint.pointsPerUnit}
              onChange={(e) =>
                patchSettings({
                  laundryPoint: {
                    ...form.laundryPoint,
                    pointsPerUnit: Number(e.target.value),
                  },
                  pointPerRupiah: Number(e.target.value),
                })
              }
            />
          </label>
        </div>
      </Card>

      <Card className="space-y-4 p-6">
        <CardTitle>Deposit Point</CardTitle>
        <p className="text-sm text-slate-500">
          Formula: floor(deposit / minimum deposit) × points per multiplier
        </p>
        <div className="grid gap-4 md:grid-cols-3">
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={form.depositPoint.enabled}
              disabled={!canEdit}
              onChange={(e) =>
                patchSettings({
                  depositPoint: { ...form.depositPoint, enabled: e.target.checked },
                })
              }
            />
            Enabled
          </label>
          <label className="space-y-1 text-sm">
            <span>Minimum Deposit (Rp)</span>
            <Input
              type="number"
              disabled={!canEdit}
              value={form.depositPoint.minimumDeposit}
              onChange={(e) =>
                patchSettings({
                  depositPoint: {
                    ...form.depositPoint,
                    minimumDeposit: Number(e.target.value),
                  },
                })
              }
            />
          </label>
          <label className="space-y-1 text-sm">
            <span>Points Per Multiplier</span>
            <Input
              type="number"
              disabled={!canEdit}
              value={form.depositPoint.pointsPerMultiplier}
              onChange={(e) =>
                patchSettings({
                  depositPoint: {
                    ...form.depositPoint,
                    pointsPerMultiplier: Number(e.target.value),
                  },
                })
              }
            />
          </label>
        </div>
      </Card>

      <Card className="space-y-4 p-6">
        <CardTitle>Point Expiration</CardTitle>
        <label className="space-y-1 text-sm">
          <span>Expiration (days)</span>
          <Input
            type="number"
            disabled={!canEdit}
            value={form.pointExpirationDays}
            onChange={(e) =>
              patchSettings({ pointExpirationDays: Number(e.target.value) })
            }
          />
        </label>
      </Card>

      <Card className="space-y-4 p-6">
        <CardTitle>Membership Levels</CardTitle>
        <div className="space-y-3">
          {form.membershipLevels.map((level, index) => (
            <div key={level.code} className="grid gap-3 rounded-lg border p-4 md:grid-cols-5">
              <Input
                disabled={!canEdit}
                value={level.name}
                onChange={(e) => {
                  const levels = [...form.membershipLevels];
                  levels[index] = { ...level, name: e.target.value };
                  patchSettings({ membershipLevels: levels });
                }}
              />
              <Input
                type="number"
                disabled={!canEdit}
                value={level.minPoints}
                onChange={(e) => {
                  const levels = [...form.membershipLevels];
                  levels[index] = { ...level, minPoints: Number(e.target.value) };
                  patchSettings({ membershipLevels: levels });
                }}
              />
              <Input
                className="md:col-span-2"
                disabled={!canEdit}
                value={level.benefits.join(", ")}
                placeholder="Benefits (comma separated)"
                onChange={(e) => {
                  const levels = [...form.membershipLevels];
                  levels[index] = {
                    ...level,
                    benefits: e.target.value
                      .split(",")
                      .map((b) => b.trim())
                      .filter(Boolean),
                  };
                  patchSettings({ membershipLevels: levels });
                }}
              />
              <label className="flex items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  disabled={!canEdit}
                  checked={level.active !== false}
                  onChange={(e) => {
                    const levels = [...form.membershipLevels];
                    levels[index] = { ...level, active: e.target.checked };
                    patchSettings({ membershipLevels: levels });
                  }}
                />
                Active
              </label>
            </div>
          ))}
        </div>
      </Card>

      <Card className="space-y-4 p-6">
        <CardTitle>Cashback</CardTitle>
        <div className="grid gap-4 md:grid-cols-2">
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              disabled={!canEdit}
              checked={form.cashback.enabled}
              onChange={(e) =>
                patchSettings({
                  cashback: { ...form.cashback, enabled: e.target.checked },
                })
              }
            />
            Enable Cashback
          </label>
          <Input
            type="number"
            disabled={!canEdit}
            value={form.cashback.value}
            placeholder="Cashback value (%)"
            onChange={(e) =>
              patchSettings({
                cashback: { ...form.cashback, value: Number(e.target.value) },
              })
            }
          />
          <Input
            type="number"
            disabled={!canEdit}
            value={form.cashback.maxAmount}
            placeholder="Max Cashback (Rp)"
            onChange={(e) =>
              patchSettings({
                cashback: {
                  ...form.cashback,
                  maxAmount: Number(e.target.value),
                },
              })
            }
          />
          <Input
            type="number"
            disabled={!canEdit}
            value={form.cashback.expirationDays}
            placeholder="Cashback expiration (days)"
            onChange={(e) =>
              patchSettings({
                cashback: {
                  ...form.cashback,
                  expirationDays: Number(e.target.value),
                },
              })
            }
          />
        </div>
      </Card>

      <Card className="space-y-4 p-6">
        <div className="flex items-center justify-between">
          <CardTitle>Reward Catalog</CardTitle>
          {canEdit ? (
            <Button
              size="sm"
              variant="outline"
              onClick={() => setEditingItemId("new")}
            >
              Add Reward
            </Button>
          ) : null}
        </div>
        {editingItemId === "new" && canEdit ? (
          <RewardCatalogEditor
            onCancel={() => setEditingItemId(null)}
            onSave={async (input) => {
              try {
                await createCatalogItem.mutateAsync(input);
                setEditingItemId(null);
                toast.success("Reward created.");
              } catch (error) {
                toast.error(getErrorMessage(error, "Failed to create reward."));
              }
            }}
          />
        ) : null}
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="border-b text-left text-slate-500">
                <th className="px-3 py-2">Code</th>
                <th className="px-3 py-2">Name</th>
                <th className="px-3 py-2">Type</th>
                <th className="px-3 py-2">Cost</th>
                <th className="px-3 py-2">CKS / Stock</th>
                <th className="px-3 py-2">Status</th>
                {canEdit ? <th className="px-3 py-2">Actions</th> : null}
              </tr>
            </thead>
            <tbody>
              {catalog.map((item) => (
                <RewardCatalogRow
                  key={item.id}
                  item={item}
                  canEdit={canEdit}
                  isEditing={editingItemId === item.id}
                  onEdit={() => setEditingItemId(item.id)}
                  onCancel={() => setEditingItemId(null)}
                />
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}

function RewardCatalogRow({
  item,
  canEdit,
  isEditing,
  onEdit,
  onCancel,
}: {
  item: RewardCatalogItem;
  canEdit: boolean;
  isEditing: boolean;
  onEdit: () => void;
  onCancel: () => void;
}) {
  const updateItem = useUpdateRewardCatalogItem(item.id);
  const toast = useToast();

  if (isEditing && canEdit) {
    return (
      <tr>
        <td colSpan={7} className="px-3 py-3">
          <RewardCatalogEditor
            initial={item}
            onCancel={onCancel}
            onSave={async (input) => {
              try {
                await updateItem.mutateAsync(input);
                onCancel();
                toast.success("Reward updated.");
              } catch (error) {
                toast.error(getErrorMessage(error, "Failed to update reward."));
              }
            }}
          />
        </td>
      </tr>
    );
  }

  return (
    <tr className="border-b">
      <td className="px-3 py-2 font-mono text-xs">{item.code}</td>
      <td className="px-3 py-2">{item.name}</td>
      <td className="px-3 py-2">{item.type}</td>
      <td className="px-3 py-2">{item.costPoints} Point</td>
      <td className="px-3 py-2">
        {item.type === "LAUNDRY_KG"
          ? `${item.kg ?? 0} KG / ${item.serviceDurationDays ?? 0} hari`
          : item.stock == null
            ? "—"
            : `${item.stock} stok`}
      </td>
      <td className="px-3 py-2">{item.isActive ? "Active" : "Inactive"}</td>
      {canEdit ? (
        <td className="px-3 py-2">
          <Button size="sm" variant="outline" onClick={onEdit}>
            Edit
          </Button>
          <Button
            size="sm"
            variant="ghost"
            className="ml-2"
            onClick={() => {
              void updateItem
                .mutateAsync({ isActive: !item.isActive })
                .then(() => toast.success("Reward status updated."))
                .catch((error) =>
                  toast.error(getErrorMessage(error, "Update failed.")),
                );
            }}
          >
            {item.isActive ? "Deactivate" : "Activate"}
          </Button>
        </td>
      ) : null}
    </tr>
  );
}

function RewardCatalogEditor({
  initial,
  onCancel,
  onSave,
}: {
  initial?: RewardCatalogItem;
  onCancel: () => void;
  onSave: (input: {
    code: string;
    name: string;
    description?: string;
    type: RewardCatalogType;
    costPoints: number;
    kg?: number;
    serviceDurationDays?: number;
    stock?: number;
    isActive?: boolean;
  }) => Promise<void>;
}) {
  const [code, setCode] = useState(initial?.code ?? "");
  const [name, setName] = useState(initial?.name ?? "");
  const [description, setDescription] = useState(initial?.description ?? "");
  const [type, setType] = useState<RewardCatalogType>(
    initial?.type ?? "PHYSICAL_GOODS",
  );
  const [costPoints, setCostPoints] = useState(initial?.costPoints ?? 5);
  const [kg, setKg] = useState(initial?.kg ?? 5);
  const [durationDays, setDurationDays] = useState(
    initial?.serviceDurationDays ?? 3,
  );
  const [stock, setStock] = useState(initial?.stock ?? 0);
  const [saving, setSaving] = useState(false);

  return (
    <div className="grid gap-3 rounded-lg border bg-slate-50 p-4 md:grid-cols-3">
      <Input
        placeholder="Code"
        value={code}
        disabled={Boolean(initial)}
        onChange={(e) => setCode(e.target.value)}
      />
      <Input placeholder="Name" value={name} onChange={(e) => setName(e.target.value)} />
      <select
        className="rounded-md border px-3 py-2 text-sm"
        value={type}
        onChange={(e) => setType(e.target.value as RewardCatalogType)}
      >
        <option value="LAUNDRY_KG">LAUNDRY_KG (CKS)</option>
        <option value="PHYSICAL_GOODS">PHYSICAL_GOODS</option>
      </select>
      <Input
        type="number"
        placeholder="Cost Points"
        value={costPoints}
        onChange={(e) => setCostPoints(Number(e.target.value))}
      />
      {type === "LAUNDRY_KG" ? (
        <>
          <Input
            type="number"
            placeholder="Free KG"
            value={kg}
            onChange={(e) => setKg(Number(e.target.value))}
          />
          <Input
            type="number"
            placeholder="Duration (days)"
            value={durationDays}
            onChange={(e) => setDurationDays(Number(e.target.value))}
          />
        </>
      ) : (
        <Input
          type="number"
          placeholder="Stock"
          value={stock}
          onChange={(e) => setStock(Number(e.target.value))}
        />
      )}
      <Input
        className="md:col-span-3"
        placeholder="Description"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
      />
      <div className="flex gap-2 md:col-span-3">
        <Button
          size="sm"
          disabled={saving || !code || !name}
          onClick={() => {
            setSaving(true);
            void onSave({
              code,
              name,
              description: description || undefined,
              type,
              costPoints,
              ...(type === "LAUNDRY_KG"
                ? { kg, serviceDurationDays: durationDays, serviceType: "CKS" }
                : { stock }),
              isActive: initial?.isActive ?? true,
            }).finally(() => setSaving(false));
          }}
        >
          Save
        </Button>
        <Button size="sm" variant="outline" onClick={onCancel}>
          Cancel
        </Button>
      </div>
    </div>
  );
}
