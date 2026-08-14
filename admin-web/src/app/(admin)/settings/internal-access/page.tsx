"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import { AccessMatrixTable } from "@/components/internal-access/access-matrix-table";
import { RoleSegmentedSelector } from "@/components/internal-access/role-selector";
import {
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { useToast } from "@/components/ui/toast";
import {
  INTERNAL_ACCESS_FEATURES,
  deriveMatrixFromPermissions,
  derivePermissionCodesFromMatrix,
  getMatrixPermissionCodes,
  syncLinkedFeatures,
} from "@/config/internal-access-features";
import {
  useAssignRolePermissions,
  useInternalRoles,
  usePermissionsCatalog,
  useRolePermissions,
} from "@/hooks/use-internal-access";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import {
  INTERNAL_ACCESS_ROLES,
  type AccessMatrixState,
  type EmployeeRole,
} from "@/types/internal-access";

function mergePermissionIds(
  currentCodes: Set<string>,
  matrixCodes: Set<string>,
): string[] {
  const matrixTracked = getMatrixPermissionCodes();
  const merged = new Set<string>();

  for (const code of currentCodes) {
    if (!matrixTracked.has(code)) {
      merged.add(code);
    }
  }

  for (const code of matrixCodes) {
    merged.add(code);
  }

  return Array.from(merged);
}

export default function InternalAccessPage() {
  const router = useRouter();
  const toast = useToast();
  const canEdit = isOwnerRole();
  const rolesQuery = useInternalRoles(canEdit);
  const permissionsQuery = usePermissionsCatalog(canEdit);
  const assignMutation = useAssignRolePermissions();

  const [selectedRole, setSelectedRole] = useState<EmployeeRole>("CASHIER");
  const [draft, setDraft] = useState<AccessMatrixState | null>(null);

  useEffect(() => {
    if (!canEdit) {
      router.replace("/settings");
    }
  }, [canEdit, router]);

  const selectedRoleRecord = useMemo(() => {
    return rolesQuery.data?.find((role) => role.apiRole === selectedRole);
  }, [rolesQuery.data, selectedRole]);

  const rolePermissionsQuery = useRolePermissions(
    canEdit ? selectedRoleRecord?.id : undefined,
  );

  const permissionIdByCode = useMemo(() => {
    const map = new Map<string, string>();
    for (const permission of permissionsQuery.data ?? []) {
      map.set(permission.code, permission.id);
    }
    return map;
  }, [permissionsQuery.data]);

  const baselineMatrix = useMemo(() => {
    const assignedCodes = new Set(
      (rolePermissionsQuery.data ?? []).map((permission) => permission.code),
    );
    return deriveMatrixFromPermissions(assignedCodes, selectedRole);
  }, [rolePermissionsQuery.data, selectedRole]);

  const matrix = draft ?? baselineMatrix;
  const isDirty = draft !== null;

  useEffect(() => {
    setDraft(null);
  }, [selectedRole, rolePermissionsQuery.dataUpdatedAt]);

  const isLoading =
    rolesQuery.isLoading ||
    permissionsQuery.isLoading ||
    rolePermissionsQuery.isLoading;

  const isError =
    rolesQuery.isError ||
    permissionsQuery.isError ||
    rolePermissionsQuery.isError;

  const queryError =
    rolesQuery.error ?? permissionsQuery.error ?? rolePermissionsQuery.error;

  function handleMatrixChange(
    featureId: string,
    patch: Partial<{
      view: boolean;
      manage: boolean;
      topUp: boolean;
      deduct: boolean;
    }>,
  ) {
    setDraft((current) => {
      const base = current ?? baselineMatrix;
      return syncLinkedFeatures(base, featureId, patch);
    });
  }

  function handleReset() {
    setDraft(null);
  }

  async function handleSave() {
    if (!selectedRoleRecord || !canEdit) return;

    const currentCodes = new Set(
      (rolePermissionsQuery.data ?? []).map((permission) => permission.code),
    );
    const matrixCodes = derivePermissionCodesFromMatrix(matrix);
    const mergedCodes = mergePermissionIds(currentCodes, matrixCodes);

    const permissionIds = mergedCodes
      .map((code) => permissionIdByCode.get(code))
      .filter((id): id is string => Boolean(id));

    const missingCodes = mergedCodes.filter(
      (code) => !permissionIdByCode.has(code),
    );

    if (missingCodes.length > 0) {
      toast.error(`Missing permission definitions: ${missingCodes.join(", ")}`);
      return;
    }

    try {
      await assignMutation.mutateAsync({
        roleId: selectedRoleRecord.id,
        permissionIds,
      });
      setDraft(null);
      toast.success(`Internal access updated for ${selectedRoleRecord.name}.`);
    } catch (error) {
      toast.error(
        getErrorMessage(error, "Failed to update internal access settings."),
      );
    }
  }

  if (!canEdit) {
    return null;
  }

  if (isLoading) {
    return <FinanceListSkeleton />;
  }

  if (isError) {
    return (
      <QueryErrorState
        title="Failed to load Internal Access"
        message={getErrorMessage(
          queryError,
          "Unable to load role and permission settings.",
        )}
        onRetry={() => {
          rolesQuery.refetch();
          permissionsQuery.refetch();
          rolePermissionsQuery.refetch();
        }}
      />
    );
  }

  const assignedCount = (rolePermissionsQuery.data ?? []).length;
  const preservedCount = (rolePermissionsQuery.data ?? []).filter(
    (permission) => !getMatrixPermissionCodes().has(permission.code),
  ).length;

  return (
    <div className="space-y-8">
      <div className="space-y-2">
        <Link href="/settings" className="text-sm text-blue-600">
          Back to Settings
        </Link>
        <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <h2 className="text-2xl font-semibold tracking-tight text-slate-900 dark:text-slate-50">
              Internal Access
            </h2>
            <p className="mt-2 max-w-3xl text-sm leading-6 text-slate-500">
              Configure which Internal App menus each role can view and manage.
              Changes apply to staff permissions on their next login or token refresh.
            </p>
          </div>
        </div>
      </div>

      <Card className="space-y-6 p-6">
        <RoleSegmentedSelector
          roles={INTERNAL_ACCESS_ROLES}
          value={selectedRole}
          onChange={setSelectedRole}
          disabled={assignMutation.isPending}
        />

        <div className="grid gap-4 md:grid-cols-3">
          <SummaryMetric
            label="Assigned permissions"
            value={String(assignedCount)}
          />
          <SummaryMetric
            label="Matrix features"
            value={String(INTERNAL_ACCESS_FEATURES.length)}
          />
          <SummaryMetric
            label="Preserved advanced permissions"
            value={String(preservedCount)}
          />
        </div>
      </Card>

      <div className="space-y-4">
        <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <h3 className="text-lg font-semibold text-slate-900 dark:text-slate-50">
              Access matrix
            </h3>
            <p className="text-sm text-slate-500">
              View controls read access. Manage controls operational actions where supported by the permission model.
            </p>
          </div>
          {selectedRole === "OWNER" ? (
            <p className="text-sm text-slate-500">
              Owner bypasses permission checks in the Internal App, but assignments remain stored for consistency.
            </p>
          ) : null}
        </div>

        <AccessMatrixTable
          features={INTERNAL_ACCESS_FEATURES}
          matrix={matrix}
          selectedRole={selectedRole}
          canEdit={canEdit}
          onChange={handleMatrixChange}
        />
      </div>

      {canEdit ? (
        <div className="flex flex-col-reverse gap-3 border-t border-slate-200 pt-6 sm:flex-row sm:justify-end dark:border-slate-800">
          <Button
            variant="outline"
            disabled={!isDirty || assignMutation.isPending}
            onClick={handleReset}
          >
            Reset changes
          </Button>
          <Button
            disabled={!isDirty || assignMutation.isPending}
            onClick={handleSave}
          >
            {assignMutation.isPending ? "Saving..." : "Save access"}
          </Button>
        </div>
      ) : null}
    </div>
  );
}

function SummaryMetric({
  label,
  value,
}: {
  label: string;
  value: string;
}) {
  return (
    <div className="rounded-xl border border-slate-200 bg-slate-50/70 px-4 py-3 dark:border-slate-800 dark:bg-slate-900/60">
      <p className="text-xs font-medium uppercase tracking-wide text-slate-500">
        {label}
      </p>
      <p className="mt-1 text-2xl font-semibold text-slate-900 dark:text-slate-50">
        {value}
      </p>
    </div>
  );
}
