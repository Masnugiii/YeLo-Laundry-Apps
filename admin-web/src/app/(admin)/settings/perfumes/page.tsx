"use client";

import Link from "next/link";
import { useState } from "react";
import {
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import {
  useCreatePerfume,
  useDeletePerfume,
  usePerfumes,
  useUpdatePerfume,
} from "@/hooks/use-master-data";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import { formatCurrency } from "@/lib/utils";
import type { LaundryPerfume } from "@/types/master-data";

type PerfumeDraft = {
  id?: string;
  code: string;
  name: string;
  extraPrice: number;
  displayOrder: number;
  isActive: boolean;
};

const emptyDraft = (): PerfumeDraft => ({
  code: "",
  name: "",
  extraPrice: 0,
  displayOrder: 0,
  isActive: true,
});

function toDraft(perfume: LaundryPerfume): PerfumeDraft {
  return {
    id: perfume.id,
    code: perfume.code,
    name: perfume.name,
    extraPrice: Number(perfume.extraPrice),
    displayOrder: perfume.displayOrder,
    isActive: perfume.isActive,
  };
}

export default function PerfumeSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const perfumesQuery = usePerfumes();
  const createPerfume = useCreatePerfume();
  const deletePerfume = useDeletePerfume();
  const [draft, setDraft] = useState<PerfumeDraft>(emptyDraft);
  const [editingId, setEditingId] = useState<string | null>(null);
  const updatePerfume = useUpdatePerfume(editingId ?? "");

  function updateField<K extends keyof PerfumeDraft>(key: K, value: PerfumeDraft[K]) {
    setDraft((current) => ({ ...current, [key]: value }));
  }

  async function handleSave() {
    if (!canEdit) return;

    try {
      if (editingId) {
        await updatePerfume.mutateAsync({
          name: draft.name,
          extraPrice: draft.extraPrice,
          displayOrder: draft.displayOrder,
          isActive: draft.isActive,
        });
        toast.success("Perfume updated.");
      } else {
        await createPerfume.mutateAsync({
          code: draft.code.trim().toUpperCase(),
          name: draft.name.trim(),
          extraPrice: draft.extraPrice,
          displayOrder: draft.displayOrder,
          isActive: draft.isActive,
        });
        toast.success("Perfume created.");
      }
      setDraft(emptyDraft());
      setEditingId(null);
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to save perfume."));
    }
  }

  async function handleDelete(id: string) {
    if (!canEdit) return;
    try {
      await deletePerfume.mutateAsync(id);
      toast.success("Perfume deactivated.");
      if (editingId === id) {
        setEditingId(null);
        setDraft(emptyDraft());
      }
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to delete perfume."));
    }
  }

  if (perfumesQuery.isLoading) return <FinanceListSkeleton />;
  if (perfumesQuery.isError) {
    return (
      <QueryErrorState
        title="Failed to load perfumes"
        message={getErrorMessage(perfumesQuery.error, "Failed to load perfumes.")}
        onRetry={() => perfumesQuery.refetch()}
      />
    );
  }

  const perfumes = perfumesQuery.data ?? [];

  return (
    <div className="space-y-6">
      <div>
        <Link href="/settings" className="text-sm text-blue-600">
          ← Back to Settings
        </Link>
        <h2 className="mt-2 text-xl font-semibold">Perfume Master</h2>
        <p className="text-sm text-slate-500">
          Manage laundry perfume options shown in customer checkout.
        </p>
      </div>

      {canEdit ? (
        <Card className="space-y-4 p-4">
          <CardTitle>{editingId ? "Edit Perfume" : "Add Perfume"}</CardTitle>
          <div className="grid gap-3 md:grid-cols-2">
            <Input
              placeholder="Code"
              value={draft.code}
              disabled={Boolean(editingId)}
              onChange={(event) => updateField("code", event.target.value)}
            />
            <Input
              placeholder="Name"
              value={draft.name}
              onChange={(event) => updateField("name", event.target.value)}
            />
            <Input
              type="number"
              placeholder="Extra price"
              value={draft.extraPrice}
              onChange={(event) =>
                updateField("extraPrice", Number(event.target.value) || 0)
              }
            />
            <Input
              type="number"
              placeholder="Display order"
              value={draft.displayOrder}
              onChange={(event) =>
                updateField("displayOrder", Number(event.target.value) || 0)
              }
            />
          </div>
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={draft.isActive}
              onChange={(event) => updateField("isActive", event.target.checked)}
            />
            Active
          </label>
          <div className="flex gap-2">
            <Button onClick={handleSave}>
              {editingId ? "Update" : "Create"}
            </Button>
            {editingId ? (
              <Button
                variant="outline"
                onClick={() => {
                  setEditingId(null);
                  setDraft(emptyDraft());
                }}
              >
                Cancel
              </Button>
            ) : null}
          </div>
        </Card>
      ) : null}

      <div className="overflow-hidden rounded-xl border">
        <table className="min-w-full divide-y divide-slate-200">
          <thead className="bg-slate-50">
            <tr>
              <th className="px-4 py-3 text-left text-sm font-medium">Code</th>
              <th className="px-4 py-3 text-left text-sm font-medium">Name</th>
              <th className="px-4 py-3 text-left text-sm font-medium">Extra Price</th>
              <th className="px-4 py-3 text-left text-sm font-medium">Order</th>
              <th className="px-4 py-3 text-left text-sm font-medium">Status</th>
              {canEdit ? (
                <th className="px-4 py-3 text-left text-sm font-medium">Actions</th>
              ) : null}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-200 bg-white">
            {perfumes.map((perfume) => (
              <tr key={perfume.id}>
                <td className="px-4 py-3 text-sm">{perfume.code}</td>
                <td className="px-4 py-3 text-sm">{perfume.name}</td>
                <td className="px-4 py-3 text-sm">
                  {formatCurrency(Number(perfume.extraPrice))}
                </td>
                <td className="px-4 py-3 text-sm">{perfume.displayOrder}</td>
                <td className="px-4 py-3 text-sm">
                  {perfume.isActive ? "Active" : "Inactive"}
                </td>
                {canEdit ? (
                  <td className="px-4 py-3 text-sm">
                    <div className="flex gap-2">
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => {
                          setEditingId(perfume.id);
                          setDraft(toDraft(perfume));
                        }}
                      >
                        Edit
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleDelete(perfume.id)}
                      >
                        Deactivate
                      </Button>
                    </div>
                  </td>
                ) : null}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
