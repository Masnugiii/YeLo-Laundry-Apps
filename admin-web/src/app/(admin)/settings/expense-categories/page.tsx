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
  useCreateExpenseCategory,
  useExpenseCategories,
  useUpdateExpenseCategory,
} from "@/hooks/use-master-data";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";

export default function ExpenseCategoriesSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const { data, isLoading, isError, error, refetch } = useExpenseCategories(true);
  const createMutation = useCreateExpenseCategory();
  const [form, setForm] = useState({ code: "", name: "" });

  if (isLoading) return <FinanceListSkeleton />;
  if (isError) {
    return (
      <QueryErrorState
        title="Failed to load expense categories"
        message={getErrorMessage(error, "Failed to load expense categories.")}
        onRetry={() => refetch()}
      />
    );
  }

  const categories = data ?? [];

  return (
    <div className="space-y-6">
      <div>
        <Link href="/settings" className="text-sm text-blue-600">
          ← Back to Settings
        </Link>
        <h2 className="mt-2 text-xl font-semibold">Expense Categories</h2>
        <p className="text-sm text-slate-500">
          Master data for expense classification.
        </p>
      </div>

      {canEdit ? (
        <div className="grid gap-3 rounded-xl border p-4 md:grid-cols-3">
          <Input
            placeholder="Code"
            value={form.code}
            onChange={(event) => setForm((current) => ({ ...current, code: event.target.value }))}
          />
          <Input
            placeholder="Name"
            value={form.name}
            onChange={(event) => setForm((current) => ({ ...current, name: event.target.value }))}
          />
          <Button
            onClick={() => {
              void createMutation
                .mutateAsync(form)
                .then(() => {
                  toast.success("Expense category created.");
                  setForm({ code: "", name: "" });
                })
                .catch((mutationError) =>
                  toast.error(getErrorMessage(mutationError, "Create failed.")),
                );
            }}
          >
            Add Category
          </Button>
        </div>
      ) : null}

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
            {categories.map((category) => (
              <ExpenseCategoryRow
                key={category.id}
                category={category}
                canEdit={canEdit}
                onUpdated={() => toast.success("Expense category updated.")}
                onError={(message) => toast.error(message)}
              />
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function ExpenseCategoryRow({
  category,
  canEdit,
  onUpdated,
  onError,
}: {
  category: { id: string; code: string; name: string; isActive: boolean };
  canEdit: boolean;
  onUpdated: () => void;
  onError: (message: string) => void;
}) {
  const updateMutation = useUpdateExpenseCategory(category.id);

  return (
    <tr>
      <td className="px-4 py-3 text-sm">{category.code}</td>
      <td className="px-4 py-3 text-sm">{category.name}</td>
      <td className="px-4 py-3 text-sm">{category.isActive ? "Active" : "Inactive"}</td>
      {canEdit ? (
        <td className="px-4 py-3 text-sm">
          <Button
            size="sm"
            variant="outline"
            onClick={() => {
              void updateMutation
                .mutateAsync({ isActive: !category.isActive })
                .then(onUpdated)
                .catch((mutationError) =>
                  onError(getErrorMessage(mutationError, "Update failed.")),
                );
            }}
          >
            {category.isActive ? "Deactivate" : "Activate"}
          </Button>
        </td>
      ) : null}
    </tr>
  );
}
