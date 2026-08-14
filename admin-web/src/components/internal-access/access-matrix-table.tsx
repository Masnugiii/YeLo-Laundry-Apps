"use client";

import { Switch } from "@/components/ui/switch";
import { cn } from "@/lib/utils";
import {
  getManagePermissionCodes,
  getRoleDefaultManage,
  isRoleDefaultManageFeature,
} from "@/config/internal-access-features";
import type {
  AccessMatrixState,
  InternalAccessFeature,
} from "@/types/internal-access";
import type { EmployeeRole } from "@/types/employee";

interface AccessMatrixTableProps {
  features: InternalAccessFeature[];
  matrix: AccessMatrixState;
  selectedRole: EmployeeRole;
  canEdit: boolean;
  onChange: (
    featureId: string,
    patch: Partial<{
      view: boolean;
      manage: boolean;
      topUp: boolean;
      deduct: boolean;
    }>,
  ) => void;
}

function permissionsAreLinked(feature: InternalAccessFeature): boolean {
  if (isRoleDefaultManageFeature(feature)) {
    return false;
  }

  if (feature.capabilityLayout === "wallet") {
    return false;
  }

  const manage = getManagePermissionCodes(feature);
  const view = feature.viewPermissions;

  return (
    manage.length === view.length &&
    manage.every((code, index) => code === view[index])
  );
}

function AccessToggleCell({
  checked,
  disabled,
  onCheckedChange,
  label,
}: {
  checked: boolean;
  disabled: boolean;
  onCheckedChange: (checked: boolean) => void;
  label: string;
}) {
  return (
    <div className="flex items-center justify-center">
      <Switch
        checked={checked}
        disabled={disabled}
        label={label}
        onCheckedChange={onCheckedChange}
      />
    </div>
  );
}

function EmptyCapabilityCell() {
  return (
    <div className="flex items-center justify-center text-sm text-slate-300 dark:text-slate-600">
      —
    </div>
  );
}

export function AccessMatrixTable({
  features,
  matrix,
  selectedRole,
  canEdit,
  onChange,
}: AccessMatrixTableProps) {
  return (
    <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900">
      <div className="overflow-x-auto">
        <table className="min-w-full text-sm">
          <thead>
            <tr className="border-b border-slate-200 bg-slate-50/80 dark:border-slate-800 dark:bg-slate-900/80">
              <th className="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">
                Feature
              </th>
              <th className="w-28 px-4 py-4 text-center text-xs font-semibold uppercase tracking-wide text-slate-500">
                View
              </th>
              <th className="w-28 px-4 py-4 text-center text-xs font-semibold uppercase tracking-wide text-slate-500">
                Top Up
              </th>
              <th className="w-28 px-4 py-4 text-center text-xs font-semibold uppercase tracking-wide text-slate-500">
                Deduct
              </th>
              <th className="w-28 px-4 py-4 text-center text-xs font-semibold uppercase tracking-wide text-slate-500">
                Manage
              </th>
            </tr>
          </thead>
          <tbody>
            {features.map((feature, index) => {
              const entry = matrix[feature.id] ?? { view: false, manage: false };
              const roleDefaultManage = isRoleDefaultManageFeature(feature);
              const linked = permissionsAreLinked(feature);
              const manageValue = roleDefaultManage
                ? getRoleDefaultManage(feature, selectedRole)
                : entry.manage;
              const isWallet = feature.capabilityLayout === "wallet";

              return (
                <tr
                  key={feature.id}
                  className={cn(
                    "border-t border-slate-100 transition-colors hover:bg-slate-50/60 dark:border-slate-800 dark:hover:bg-slate-800/40",
                    index === 0 && "border-t-0",
                  )}
                >
                  <td className="px-6 py-5">
                    <div className="space-y-1">
                      <p className="font-medium text-slate-900 dark:text-slate-100">
                        {feature.label}
                      </p>
                      <p className="text-sm text-slate-500">{feature.description}</p>
                      {isWallet ? (
                        <div className="space-y-0.5 pt-1 text-xs text-slate-400">
                          <p>View — {feature.viewHint}</p>
                          <p>Top Up — {feature.topUpHint}</p>
                          <p>Deduct — {feature.deductHint}</p>
                        </div>
                      ) : null}
                      {roleDefaultManage ? (
                        <p className="text-xs text-slate-400">
                          Manage access follows role architecture in the Internal App.
                        </p>
                      ) : null}
                    </div>
                  </td>
                  <td className="px-4 py-5">
                    <AccessToggleCell
                      checked={entry.view}
                      disabled={!canEdit}
                      label={`${feature.label} view access`}
                      onCheckedChange={(checked) => {
                        if (isWallet) {
                          onChange(feature.id, { view: checked });
                          return;
                        }

                        if (linked) {
                          onChange(feature.id, { view: checked, manage: checked });
                          return;
                        }

                        onChange(feature.id, {
                          view: checked,
                          manage: checked ? entry.manage : false,
                        });
                      }}
                    />
                  </td>
                  <td className="px-4 py-5">
                    {isWallet ? (
                      <AccessToggleCell
                        checked={entry.topUp ?? false}
                        disabled={!canEdit || !entry.view}
                        label={`${feature.label} top up access`}
                        onCheckedChange={(checked) => {
                          onChange(feature.id, { topUp: checked });
                        }}
                      />
                    ) : (
                      <EmptyCapabilityCell />
                    )}
                  </td>
                  <td className="px-4 py-5">
                    {isWallet ? (
                      <AccessToggleCell
                        checked={entry.deduct ?? false}
                        disabled={!canEdit || !entry.view}
                        label={`${feature.label} deduct access`}
                        onCheckedChange={(checked) => {
                          onChange(feature.id, { deduct: checked });
                        }}
                      />
                    ) : (
                      <EmptyCapabilityCell />
                    )}
                  </td>
                  <td className="px-4 py-5">
                    {isWallet ? (
                      <EmptyCapabilityCell />
                    ) : (
                      <AccessToggleCell
                        checked={manageValue}
                        disabled={!canEdit || roleDefaultManage || !entry.view}
                        label={`${feature.label} manage access`}
                        onCheckedChange={(checked) => {
                          if (linked) {
                            onChange(feature.id, { view: checked, manage: checked });
                            return;
                          }

                          onChange(feature.id, {
                            manage: checked,
                            view: checked ? true : entry.view,
                          });
                        }}
                      />
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
