"use client";

import { cn } from "@/lib/utils";
import type { EmployeeRole } from "@/types/employee";
import { INTERNAL_ROLE_LABELS } from "@/types/internal-access";

interface RoleSelectorProps {
  roles: EmployeeRole[];
  value: EmployeeRole;
  onChange: (role: EmployeeRole) => void;
  disabled?: boolean;
}

export function RoleSelector({
  roles,
  value,
  onChange,
  disabled = false,
}: RoleSelectorProps) {
  return (
    <div className="space-y-3">
      <label
        htmlFor="internal-access-role"
        className="text-sm font-medium text-slate-700 dark:text-slate-200"
      >
        Role
      </label>
      <select
        id="internal-access-role"
        value={value}
        disabled={disabled}
        onChange={(event) => onChange(event.target.value as EmployeeRole)}
        className={cn(
          "h-11 w-full max-w-md rounded-xl border border-slate-200 bg-white px-4 text-sm font-medium text-slate-900 shadow-sm",
          "transition-colors hover:border-slate-300 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20",
          "disabled:cursor-not-allowed disabled:opacity-60",
          "dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100",
        )}
      >
        {roles.map((role) => (
          <option key={role} value={role}>
            {INTERNAL_ROLE_LABELS[role]}
          </option>
        ))}
      </select>
    </div>
  );
}

interface RoleSegmentedSelectorProps {
  roles: EmployeeRole[];
  value: EmployeeRole;
  onChange: (role: EmployeeRole) => void;
  disabled?: boolean;
}

export function RoleSegmentedSelector({
  roles,
  value,
  onChange,
  disabled = false,
}: RoleSegmentedSelectorProps) {
  return (
    <div className="space-y-3">
      <p className="text-sm font-medium text-slate-700 dark:text-slate-200">
        Role
      </p>
      <div className="flex flex-wrap gap-2">
        {roles.map((role) => {
          const isActive = role === value;

          return (
            <button
              key={role}
              type="button"
              disabled={disabled}
              onClick={() => onChange(role)}
              className={cn(
                "rounded-full border px-4 py-2 text-sm font-medium transition-colors",
                "disabled:cursor-not-allowed disabled:opacity-60",
                isActive
                  ? "border-blue-600 bg-blue-600 text-white shadow-sm"
                  : "border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800",
              )}
            >
              {INTERNAL_ROLE_LABELS[role]}
            </button>
          );
        })}
      </div>
    </div>
  );
}
