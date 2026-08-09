"use client";

import Link from "next/link";
import {
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { useToast } from "@/components/ui/toast";
import { usePaymentMethods, useUpdatePaymentMethod } from "@/hooks/use-master-data";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";

export default function PaymentMethodsSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const { data, isLoading, isError, error, refetch } = usePaymentMethods(true);

  if (isLoading) return <FinanceListSkeleton />;
  if (isError) {
    return (
      <QueryErrorState
        title="Failed to load payment methods"
        message={getErrorMessage(error, "Failed to load payment methods.")}
        onRetry={() => refetch()}
      />
    );
  }

  const methods = data ?? [];

  return (
    <div className="space-y-6">
      <div>
        <Link href="/settings" className="text-sm text-blue-600">
          ← Back to Settings
        </Link>
        <h2 className="mt-2 text-xl font-semibold">Payment Methods</h2>
        <p className="text-sm text-slate-500">
          Cash, QRIS, transfer, and wallet payment configuration.
        </p>
      </div>

      <div className="overflow-hidden rounded-xl border">
        <table className="min-w-full divide-y divide-slate-200">
          <thead className="bg-slate-50">
            <tr>
              <th className="px-4 py-3 text-left text-sm font-medium">Code</th>
              <th className="px-4 py-3 text-left text-sm font-medium">Name</th>
              <th className="px-4 py-3 text-left text-sm font-medium">Status</th>
              {canEdit ? <th className="px-4 py-3 text-left text-sm font-medium">Actions</th> : null}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-200 bg-white">
            {methods.map((method) => (
              <PaymentMethodRow
                key={method.id}
                method={method}
                canEdit={canEdit}
                onUpdated={() => toast.success("Payment method updated.")}
                onError={(message) => toast.error(message)}
              />
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function PaymentMethodRow({
  method,
  canEdit,
  onUpdated,
  onError,
}: {
  method: { id: string; code: string; name: string; isActive: boolean };
  canEdit: boolean;
  onUpdated: () => void;
  onError: (message: string) => void;
}) {
  const updateMutation = useUpdatePaymentMethod(method.id);

  return (
    <tr>
      <td className="px-4 py-3 text-sm">{method.code}</td>
      <td className="px-4 py-3 text-sm">{method.name}</td>
      <td className="px-4 py-3 text-sm">{method.isActive ? "Active" : "Inactive"}</td>
      {canEdit ? (
        <td className="px-4 py-3 text-sm">
          <Button
            size="sm"
            variant="outline"
            onClick={() => {
              void updateMutation
                .mutateAsync({ isActive: !method.isActive })
                .then(onUpdated)
                .catch((mutationError) =>
                  onError(getErrorMessage(mutationError, "Update failed.")),
                );
            }}
          >
            {method.isActive ? "Deactivate" : "Activate"}
          </Button>
        </td>
      ) : null}
    </tr>
  );
}
