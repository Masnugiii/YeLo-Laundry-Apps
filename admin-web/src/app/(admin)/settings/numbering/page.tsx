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
  useNumberingConfigurations,
  useUpdateNumbering,
} from "@/hooks/use-master-data";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import type { NumberingSequence } from "@/types/master-data";

export default function NumberingSettingsPage() {
  const toast = useToast();
  const canEdit = isOwnerRole();
  const { data, isLoading, isError, error, refetch } = useNumberingConfigurations();
  const [draft, setDraft] = useState<Record<string, NumberingSequence>>({});

  if (isLoading) return <FinanceListSkeleton />;
  if (isError) {
    return (
      <QueryErrorState
        title="Failed to load numbering configuration"
        message={getErrorMessage(error, "Failed to load numbering configuration.")}
        onRetry={() => refetch()}
      />
    );
  }

  const sequences = data ?? [];

  return (
    <div className="space-y-6">
      <div>
        <Link href="/settings" className="text-sm text-blue-600">
          ← Back to Settings
        </Link>
        <h2 className="mt-2 text-xl font-semibold">Business Numbering</h2>
        <p className="text-sm text-slate-500">
          ORD, INV, EXP, PAY, CST, and EMP numbering rules.
        </p>
      </div>

      <div className="overflow-hidden rounded-xl border">
        <table className="min-w-full divide-y divide-slate-200">
          <thead className="bg-slate-50">
            <tr>
              <th className="px-4 py-3 text-left text-sm font-medium">Type</th>
              <th className="px-4 py-3 text-left text-sm font-medium">Prefix</th>
              <th className="px-4 py-3 text-left text-sm font-medium">Padding</th>
              <th className="px-4 py-3 text-left text-sm font-medium">Daily Reset</th>
              <th className="px-4 py-3 text-left text-sm font-medium">Counter</th>
              <th className="px-4 py-3 text-left text-sm font-medium">Status</th>
              {canEdit ? <th className="px-4 py-3 text-left text-sm font-medium">Save</th> : null}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-200 bg-white">
            {sequences.map((sequence) => (
              <NumberingRow
                key={sequence.type}
                sequence={draft[sequence.type] ?? sequence}
                canEdit={canEdit}
                onChange={(updated) =>
                  setDraft((current) => ({ ...current, [sequence.type]: updated }))
                }
                onSaved={() => toast.success(`${sequence.type} numbering updated.`)}
                onError={(message) => toast.error(message)}
              />
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function NumberingRow({
  sequence,
  canEdit,
  onChange,
  onSaved,
  onError,
}: {
  sequence: NumberingSequence;
  canEdit: boolean;
  onChange: (sequence: NumberingSequence) => void;
  onSaved: () => void;
  onError: (message: string) => void;
}) {
  const updateMutation = useUpdateNumbering(sequence.type);

  return (
    <tr>
      <td className="px-4 py-3 text-sm font-medium">{sequence.type}</td>
      <td className="px-4 py-3 text-sm">
        {canEdit ? (
          <Input
            value={sequence.prefix}
            onChange={(event) => onChange({ ...sequence, prefix: event.target.value })}
          />
        ) : (
          sequence.prefix
        )}
      </td>
      <td className="px-4 py-3 text-sm">
        {canEdit ? (
          <Input
            type="number"
            value={sequence.padding}
            onChange={(event) =>
              onChange({ ...sequence, padding: Number(event.target.value) })
            }
          />
        ) : (
          sequence.padding
        )}
      </td>
      <td className="px-4 py-3 text-sm">{sequence.dailyReset ? "Yes" : "No"}</td>
      <td className="px-4 py-3 text-sm">{sequence.currentCounter}</td>
      <td className="px-4 py-3 text-sm">{sequence.isActive ? "Active" : "Inactive"}</td>
      {canEdit ? (
        <td className="px-4 py-3 text-sm">
          <Button
            size="sm"
            onClick={() => {
              void updateMutation
                .mutateAsync({
                  prefix: sequence.prefix,
                  padding: sequence.padding,
                  dailyReset: sequence.dailyReset,
                  isActive: sequence.isActive,
                })
                .then(onSaved)
                .catch((mutationError) =>
                  onError(getErrorMessage(mutationError, "Failed to update numbering.")),
                );
            }}
          >
            Save
          </Button>
        </td>
      ) : null}
    </tr>
  );
}
