"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import { usePayrollSettings, useUpdatePayrollSettings } from "@/hooks/use-payroll";
import { getErrorMessage } from "@/lib/errors";
import type { PayrollPeriodType, PayrollSettings } from "@/types/payroll";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";

const PERIOD_OPTIONS: { value: PayrollPeriodType; label: string }[] = [
  { value: "weekly", label: "Weekly" },
  { value: "biweekly", label: "Biweekly" },
  { value: "monthly", label: "Monthly" },
];

export function PayrollSettingsForm() {
  const toast = useToast();
  const settingsQuery = usePayrollSettings();
  const updateMutation = useUpdatePayrollSettings();
  const [draft, setDraft] = useState<PayrollSettings | null>(null);

  const form = draft ?? settingsQuery.data ?? null;

  if (settingsQuery.isLoading) return <FinanceListSkeleton />;
  if (settingsQuery.isError) {
    return (
      <QueryErrorState
        title="Failed to load payroll settings"
        message={getErrorMessage(settingsQuery.error, "Unable to load salary rules.")}
        onRetry={() => settingsQuery.refetch()}
      />
    );
  }
  if (!form) {
    return (
      <EmptyState
        title="No settings found"
        description="Payroll salary rules are not available."
      />
    );
  }

  function updateField<K extends keyof PayrollSettings>(key: K, value: PayrollSettings[K]) {
    setDraft((current) => {
      const base = current ?? settingsQuery.data;
      return base ? { ...base, [key]: value } : current;
    });
  }

  async function handleSave() {
    if (!form) return;
    try {
      await updateMutation.mutateAsync(form);
      setDraft(null);
      toast.success("Payroll settings saved successfully.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to save payroll settings."));
    }
  }

  return (
    <Card>
      <CardTitle>Salary Rules</CardTitle>
      <p className="mt-1 text-sm text-slate-500">
        Configure production rates, attendance bonus, and payroll schedule without changing source code.
      </p>
      <div className="mt-6 grid gap-4 md:grid-cols-2">
        <label className="space-y-1 text-sm">
          <span className="font-medium">Laundry Kg Rate</span>
          <Input
            type="number"
            value={form.laundryKgRate}
            onChange={(e) => updateField("laundryKgRate", Number(e.target.value))}
          />
        </label>
        <label className="space-y-1 text-sm">
          <span className="font-medium">Laundry Piece Rate</span>
          <Input
            type="number"
            value={form.laundryPieceRate}
            onChange={(e) => updateField("laundryPieceRate", Number(e.target.value))}
          />
        </label>
        <label className="space-y-1 text-sm">
          <span className="font-medium">Ironing Kg Rate</span>
          <Input
            type="number"
            value={form.ironingKgRate}
            onChange={(e) => updateField("ironingKgRate", Number(e.target.value))}
          />
        </label>
        <label className="space-y-1 text-sm">
          <span className="font-medium">Ironing Piece Rate</span>
          <Input
            type="number"
            value={form.ironingPieceRate}
            onChange={(e) => updateField("ironingPieceRate", Number(e.target.value))}
          />
        </label>
        <label className="space-y-1 text-sm">
          <span className="font-medium">Attendance Bonus / Day</span>
          <Input
            type="number"
            value={form.attendanceBonusPerDay}
            onChange={(e) => updateField("attendanceBonusPerDay", Number(e.target.value))}
          />
        </label>
        <label className="space-y-1 text-sm">
          <span className="font-medium">Manager Weekly Salary</span>
          <Input
            type="number"
            value={form.managerWeeklySalary}
            onChange={(e) => updateField("managerWeeklySalary", Number(e.target.value))}
          />
        </label>
        <label className="space-y-1 text-sm">
          <span className="font-medium">Operator Weekly Salary</span>
          <Input
            type="number"
            value={form.operatorWeeklySalary}
            onChange={(e) => updateField("operatorWeeklySalary", Number(e.target.value))}
          />
        </label>
        <label className="space-y-1 text-sm">
          <span className="font-medium">Payroll Schedule Days</span>
          <Input
            value={form.payrollScheduleDays.join(", ")}
            onChange={(e) =>
              updateField(
                "payrollScheduleDays",
                e.target.value
                  .split(",")
                  .map((value) => Number(value.trim()))
                  .filter((value) => !Number.isNaN(value)),
              )
            }
            placeholder="1, 8, 16, 24"
          />
        </label>
        <label className="space-y-1 text-sm">
          <span className="font-medium">Payroll Period Type</span>
          <select
            className="flex h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-sm dark:border-slate-800 dark:bg-slate-950"
            value={form.periodType}
            onChange={(e) => updateField("periodType", e.target.value as PayrollPeriodType)}
          >
            {PERIOD_OPTIONS.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </label>
      </div>
      <div className="mt-6 flex justify-end">
        <Button onClick={handleSave} disabled={updateMutation.isPending}>
          {updateMutation.isPending ? "Saving..." : "Save Settings"}
        </Button>
      </div>
    </Card>
  );
}
