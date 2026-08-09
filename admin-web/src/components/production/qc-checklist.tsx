"use client";

import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import type { QcChecklistState } from "@/types/production";

interface QcChecklistProps {
  value: QcChecklistState;
  onChange: (value: QcChecklistState) => void;
  onSubmit: (passed: boolean) => void;
  loading?: boolean;
}

const CHECKLIST_ITEMS: Array<{
  key: keyof Omit<QcChecklistState, "operatorNotes">;
  label: string;
}> = [
  { key: "clean", label: "Clean" },
  { key: "dry", label: "Dry" },
  { key: "ironed", label: "Ironed" },
  { key: "folded", label: "Folded" },
  { key: "packaging", label: "Packaging" },
  { key: "perfume", label: "Perfume" },
  { key: "specialRequestCompleted", label: "Special Request Completed" },
];

export function QcChecklist({
  value,
  onChange,
  onSubmit,
  loading = false,
}: QcChecklistProps) {
  const allChecked = CHECKLIST_ITEMS.every((item) => value[item.key]);

  return (
    <Card className="space-y-4">
      <h3 className="text-lg font-semibold text-slate-900 dark:text-slate-100">
        Quality Control
      </h3>
      <div className="grid gap-3 md:grid-cols-2">
        {CHECKLIST_ITEMS.map((item) => (
          <label
            key={item.key}
            className="flex items-center gap-2 text-sm text-slate-700 dark:text-slate-200"
          >
            <input
              type="checkbox"
              checked={value[item.key]}
              onChange={(event) =>
                onChange({ ...value, [item.key]: event.target.checked })
              }
            />
            {item.label}
          </label>
        ))}
      </div>
      <div>
        <label className="mb-2 block text-sm font-medium text-slate-700 dark:text-slate-200">
          Operator Notes
        </label>
        <Input
          value={value.operatorNotes}
          onChange={(event) =>
            onChange({ ...value, operatorNotes: event.target.value })
          }
          placeholder="Add QC notes"
        />
      </div>
      <div className="flex flex-wrap gap-2">
        <Button
          disabled={loading || !allChecked}
          onClick={() => onSubmit(true)}
        >
          Pass QC
        </Button>
        <Button
          variant="destructive"
          disabled={loading}
          onClick={() => onSubmit(false)}
        >
          Fail QC
        </Button>
      </div>
    </Card>
  );
}
