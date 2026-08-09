"use client";

import Link from "next/link";
import { useState } from "react";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import { useCatalogServices, useUpdateService } from "@/hooks/use-master-data";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import type { CatalogService } from "@/types/master-data";

export default function ServicesSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const { data, isLoading, isError, error, refetch } = useCatalogServices(true);

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

  const services = data ?? [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <Link href="/settings" className="text-sm text-blue-600">
            ← Back to Settings
          </Link>
          <h2 className="mt-2 text-xl font-semibold">Services</h2>
          <p className="text-sm text-slate-500">
            {canEdit ? "Owner can edit service master data." : "View-only for Manager."}
          </p>
        </div>
      </div>

      {services.length === 0 ? (
        <EmptyState title="No services found" description="Seed or create services from backend." />
      ) : (
        <div className="overflow-hidden rounded-xl border">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-4 py-3 text-left text-sm font-medium">Code</th>
                <th className="px-4 py-3 text-left text-sm font-medium">Name</th>
                <th className="px-4 py-3 text-left text-sm font-medium">Category</th>
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
                  onUpdated={() => toast.success("Service updated.")}
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
  const [editing, setEditing] = useState(false);
  const updateMutation = useUpdateService(service.id);

  return (
    <tr>
      <td className="px-4 py-3 text-sm">{service.serviceCode}</td>
      <td className="px-4 py-3 text-sm">
        {editing ? (
          <Input
            defaultValue={service.serviceName}
            onBlur={(event) => {
              void updateMutation
                .mutateAsync({ serviceName: event.target.value })
                .then(() => {
                  onUpdated();
                  setEditing(false);
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
      <td className="px-4 py-3 text-sm">{service.category.name}</td>
      <td className="px-4 py-3 text-sm">{service.isActive ? "Active" : "Inactive"}</td>
      {canEdit ? (
        <td className="px-4 py-3 text-sm">
          <Button size="sm" variant="outline" onClick={() => setEditing(true)}>
            Edit
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
