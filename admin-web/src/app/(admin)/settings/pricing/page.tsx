"use client";

import Link from "next/link";
import { useState } from "react";
import {
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import {
  useCatalogServices,
  useCreateServicePrice,
  useServicePrices,
  useUpdateServicePrice,
} from "@/hooks/use-master-data";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { ServicePrice } from "@/types/master-data";

export default function PricingSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const servicesQuery = useCatalogServices(true);
  const [serviceId, setServiceId] = useState("");
  const pricesQuery = useServicePrices(serviceId || undefined);
  const createPrice = useCreateServicePrice();
  const [newPrice, setNewPrice] = useState(0);

  if (servicesQuery.isLoading) return <FinanceListSkeleton />;
  if (servicesQuery.isError) {
    return (
      <QueryErrorState
        title="Failed to load services"
        message={getErrorMessage(servicesQuery.error, "Failed to load services.")}
        onRetry={() => servicesQuery.refetch()}
      />
    );
  }

  const services = servicesQuery.data ?? [];
  const prices = pricesQuery.data ?? [];

  return (
    <div className="space-y-6">
      <div>
        <Link href="/settings" className="text-sm text-blue-600">
          ← Back to Settings
        </Link>
        <h2 className="mt-2 text-xl font-semibold">Pricing</h2>
        <p className="text-sm text-slate-500">
          Manage active service prices. Only one active price per service is allowed.
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <div>
          <label className="mb-1 block text-sm">Service</label>
          <select
            className="w-full rounded-md border px-3 py-2 text-sm"
            value={serviceId}
            onChange={(event) => setServiceId(event.target.value)}
          >
            <option value="">All services</option>
            {services.map((service) => (
              <option key={service.id} value={service.id}>
                {service.serviceCode} — {service.serviceName}
              </option>
            ))}
          </select>
        </div>
        {canEdit && serviceId ? (
          <div className="flex items-end gap-2">
            <div className="flex-1">
              <label className="mb-1 block text-sm">New Price (IDR)</label>
              <Input
                type="number"
                value={newPrice}
                onChange={(event) => setNewPrice(Number(event.target.value))}
              />
            </div>
            <Button
              onClick={() => {
                void createPrice
                  .mutateAsync({ serviceId, price: newPrice, isActive: true })
                  .then(() => toast.success("Price created."))
                  .catch((mutationError) =>
                    toast.error(getErrorMessage(mutationError, "Failed to create price.")),
                  );
              }}
            >
              Add Price
            </Button>
          </div>
        ) : null}
      </div>

      {pricesQuery.isLoading ? (
        <FinanceListSkeleton />
      ) : (
        <div className="overflow-hidden rounded-xl border">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-4 py-3 text-left text-sm font-medium">Service</th>
                <th className="px-4 py-3 text-left text-sm font-medium">Price</th>
                <th className="px-4 py-3 text-left text-sm font-medium">Effective</th>
                <th className="px-4 py-3 text-left text-sm font-medium">Status</th>
                {canEdit ? <th className="px-4 py-3 text-left text-sm font-medium">Actions</th> : null}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 bg-white">
              {prices.map((price) => (
                <PriceRow
                  key={price.id}
                  price={price}
                  canEdit={canEdit}
                  onUpdated={() => toast.success("Price activated.")}
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

function PriceRow({
  price,
  canEdit,
  onUpdated,
  onError,
}: {
  price: ServicePrice;
  canEdit: boolean;
  onUpdated: () => void;
  onError: (message: string) => void;
}) {
  const updatePrice = useUpdateServicePrice(price.id);

  return (
    <tr>
      <td className="px-4 py-3 text-sm">
        {price.service?.serviceCode} — {price.service?.serviceName}
      </td>
      <td className="px-4 py-3 text-sm">{formatCurrency(Number(price.price))}</td>
      <td className="px-4 py-3 text-sm">{formatDate(price.effectiveDate)}</td>
      <td className="px-4 py-3 text-sm">{price.isActive ? "Active" : "Inactive"}</td>
      {canEdit ? (
        <td className="px-4 py-3 text-sm">
          <Button
            size="sm"
            variant="outline"
            onClick={() => {
              void updatePrice
                .mutateAsync({ isActive: true })
                .then(onUpdated)
                .catch((mutationError) =>
                  onError(getErrorMessage(mutationError, "Update failed.")),
                );
            }}
          >
            Set Active
          </Button>
        </td>
      ) : null}
    </tr>
  );
}
