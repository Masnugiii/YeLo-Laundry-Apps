"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import {
  useCatalogServices,
  useCreateService,
  useCreateServicePrice,
  useUpdateService,
} from "@/hooks/use-master-data";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import { formatCurrency } from "@/lib/utils";
import type { CatalogService, ServiceCategoryRef } from "@/types/master-data";

export default function ServicesSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const { data, isLoading, isError, error, refetch } = useCatalogServices(true);
  const createService = useCreateService();
  const createPrice = useCreateServicePrice();

  const [showAddForm, setShowAddForm] = useState(false);
  const [newCode, setNewCode] = useState("");
  const [newName, setNewName] = useState("");
  const [newUnit, setNewUnit] = useState("kg");
  const [newPrice, setNewPrice] = useState(0);
  const [newCategoryId, setNewCategoryId] = useState("");

  const services = data ?? [];

  const categories = useMemo(() => {
    const map = new Map<string, ServiceCategoryRef>();
    for (const service of services) {
      map.set(service.category.id, service.category);
    }
    return [...map.values()];
  }, [services]);

  if (isLoading) return <FinanceListSkeleton />;
  if (isError) {
    return (
      <QueryErrorState
        title="Failed to load services"
        message={getErrorMessage(error, "Failed to load services.")}
        onRetry={() => refetch()}
      />
    );
  }

  async function handleCreateService() {
    const categoryId = newCategoryId || categories[0]?.id;
    if (!categoryId || !newCode.trim() || !newName.trim()) {
      toast.error("Service code, name, and category are required.");
      return;
    }

    try {
      const unitType = newUnit === "piece" || newUnit === "item" ? newUnit : "kg";
      const service = await createService.mutateAsync({
        categoryId,
        serviceCode: newCode.trim().toUpperCase(),
        serviceName: newName.trim(),
        unitType,
        weight: unitType === "kg",
        piece: unitType === "piece" || unitType === "item",
        isActive: true,
      });

      if (newPrice > 0) {
        await createPrice.mutateAsync({
          serviceId: service.id,
          price: newPrice,
          isActive: true,
        });
      }

      toast.success("Service created.");
      setShowAddForm(false);
      setNewCode("");
      setNewName("");
      setNewPrice(0);
      await refetch();
    } catch (mutationError) {
      toast.error(getErrorMessage(mutationError, "Failed to create service."));
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <Link href="/settings" className="text-sm text-blue-600">
            ← Back to Settings
          </Link>
          <h2 className="mt-2 text-xl font-semibold">Services</h2>
          <p className="text-sm text-slate-500">
            {canEdit
              ? "Kelola jasa laundry dan harga aktif dari database."
              : "View-only for Manager."}
          </p>
        </div>
        {canEdit ? (
          <Button variant="outline" onClick={() => setShowAddForm((value) => !value)}>
            {showAddForm ? "Cancel" : "Add Service"}
          </Button>
        ) : null}
      </div>

      {showAddForm && canEdit ? (
        <Card className="space-y-4 p-5">
          <h3 className="font-medium text-slate-800">Tambah Jasa Baru</h3>
          <div className="grid gap-3 md:grid-cols-2">
            <Input
              placeholder="Service code (e.g. WASH_DRY)"
              value={newCode}
              onChange={(event) => setNewCode(event.target.value)}
            />
            <Input
              placeholder="Service name"
              value={newName}
              onChange={(event) => setNewName(event.target.value)}
            />
            <select
              className="h-10 rounded-md border px-3 text-sm"
              value={newUnit}
              onChange={(event) => setNewUnit(event.target.value)}
            >
              <option value="kg">KG</option>
              <option value="piece">PCS</option>
              <option value="item">ITEM</option>
            </select>
            <Input
              type="number"
              placeholder="Price (IDR)"
              value={newPrice || ""}
              onChange={(event) => setNewPrice(Number(event.target.value))}
            />
            {categories.length > 0 ? (
              <select
                className="h-10 rounded-md border px-3 text-sm md:col-span-2"
                value={newCategoryId || categories[0]?.id}
                onChange={(event) => setNewCategoryId(event.target.value)}
              >
                {categories.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.name}
                  </option>
                ))}
              </select>
            ) : null}
          </div>
          <Button onClick={() => void handleCreateService()} disabled={createService.isPending}>
            Save Service
          </Button>
        </Card>
      ) : null}

      {services.length === 0 ? (
        <EmptyState title="No services found" description="Seed or create services from backend." />
      ) : (
        <div className="overflow-hidden rounded-xl border">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-4 py-3 text-left text-sm font-medium">Code</th>
                <th className="px-4 py-3 text-left text-sm font-medium">Name</th>
                <th className="px-4 py-3 text-left text-sm font-medium">Unit</th>
                <th className="px-4 py-3 text-left text-sm font-medium">Price</th>
                <th className="px-4 py-3 text-left text-sm font-medium">Status</th>
                {canEdit ? <th className="px-4 py-3 text-left text-sm font-medium">Actions</th> : null}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 bg-white">
              {services.map((service) => (
                <ServiceRow
                  key={service.id}
                  service={service}
                  canEdit={canEdit}
                  onUpdated={() => {
                    void refetch();
                    toast.success("Service updated.");
                  }}
                  onError={(message) => toast.error(message)}
                />
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function ServiceRow({
  service,
  canEdit,
  onUpdated,
  onError,
}: {
  service: CatalogService;
  canEdit: boolean;
  onUpdated: () => void;
  onError: (message: string) => void;
}) {
  const [editingName, setEditingName] = useState(false);
  const [editingPrice, setEditingPrice] = useState(false);
  const updateMutation = useUpdateService(service.id);
  const createPriceMutation = useCreateServicePrice();
  const activePrice = service.prices?.[0]?.price;
  const [priceDraft, setPriceDraft] = useState(
    activePrice != null ? String(Number(activePrice)) : "",
  );

  async function savePrice() {
    const nextPrice = Number(priceDraft);
    if (!Number.isFinite(nextPrice) || nextPrice < 0) {
      onError("Price must be zero or greater.");
      return;
    }

    try {
      await createPriceMutation.mutateAsync({
        serviceId: service.id,
        price: nextPrice,
        isActive: true,
      });
      setEditingPrice(false);
      onUpdated();
    } catch (mutationError) {
      onError(getErrorMessage(mutationError, "Failed to update price."));
    }
  }

  return (
    <tr>
      <td className="px-4 py-3 text-sm font-mono">{service.serviceCode}</td>
      <td className="px-4 py-3 text-sm">
        {editingName ? (
          <Input
            defaultValue={service.serviceName}
            onBlur={(event) => {
              void updateMutation
                .mutateAsync({ serviceName: event.target.value })
                .then(() => {
                  setEditingName(false);
                  onUpdated();
                })
                .catch((mutationError) =>
                  onError(getErrorMessage(mutationError, "Update failed.")),
                );
            }}
          />
        ) : (
          service.serviceName
        )}
      </td>
      <td className="px-4 py-3 text-sm uppercase">{service.unitType}</td>
      <td className="px-4 py-3 text-sm">
        {editingPrice ? (
          <div className="flex items-center gap-2">
            <Input
              type="number"
              value={priceDraft}
              onChange={(event) => setPriceDraft(event.target.value)}
              className="w-28"
            />
            <Button size="sm" onClick={() => void savePrice()} disabled={createPriceMutation.isPending}>
              Save
            </Button>
            <Button size="sm" variant="ghost" onClick={() => setEditingPrice(false)}>
              Cancel
            </Button>
          </div>
        ) : activePrice != null ? (
          formatCurrency(Number(activePrice))
        ) : (
          "—"
        )}
      </td>
      <td className="px-4 py-3 text-sm">{service.isActive ? "Active" : "Inactive"}</td>
      {canEdit ? (
        <td className="px-4 py-3 text-sm">
          <Button size="sm" variant="outline" onClick={() => setEditingName(true)}>
            Edit Name
          </Button>
          <Button
            size="sm"
            variant="outline"
            className="ml-2"
            onClick={() => {
              setPriceDraft(activePrice != null ? String(Number(activePrice)) : "");
              setEditingPrice(true);
            }}
          >
            Edit Price
          </Button>
          <Button
            size="sm"
            variant="ghost"
            className="ml-2"
            onClick={() => {
              void updateMutation
                .mutateAsync({ isActive: !service.isActive })
                .then(onUpdated)
                .catch((mutationError) =>
                  onError(getErrorMessage(mutationError, "Update failed.")),
                );
            }}
          >
            {service.isActive ? "Deactivate" : "Activate"}
          </Button>
        </td>
      ) : null}
    </tr>
  );
}
