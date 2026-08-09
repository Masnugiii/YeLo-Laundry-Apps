"use client";

import Link from "next/link";
import type { ReactNode } from "react";
import {
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";

interface SettingsSectionShellProps {
  title: string;
  description: string;
  isLoading: boolean;
  isError: boolean;
  error: unknown;
  onRetry: () => void;
  children: ReactNode;
  onSave?: () => void;
  isSaving?: boolean;
  saveLabel?: string;
}

export function SettingsSectionShell({
  title,
  description,
  isLoading,
  isError,
  error,
  onRetry,
  children,
  onSave,
  isSaving = false,
  saveLabel = "Save changes",
}: SettingsSectionShellProps) {
  const canEdit = isOwnerRole();

  if (isLoading) return <FinanceListSkeleton />;
  if (isError) {
    return (
      <QueryErrorState
        title={`Failed to load ${title}`}
        message={getErrorMessage(error, `Unable to load ${title.toLowerCase()}.`)}
        onRetry={onRetry}
      />
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <Link href="/settings" className="text-sm text-blue-600">
          ← Back to Settings
        </Link>
        <h2 className="mt-2 text-xl font-semibold">{title}</h2>
        <p className="text-sm text-slate-500">{description}</p>
        {!canEdit ? (
          <p className="mt-2 text-sm text-amber-700">
            Read-only view. Only Owner can modify configuration.
          </p>
        ) : null}
      </div>

      {children}

      {canEdit && onSave ? (
        <div className="flex justify-end">
          <Button onClick={onSave} disabled={isSaving}>
            {isSaving ? "Saving..." : saveLabel}
          </Button>
        </div>
      ) : null}
    </div>
  );
}
