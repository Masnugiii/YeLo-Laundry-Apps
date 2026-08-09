"use client";

import { Button } from "@/components/ui/button";
import { formatDate } from "@/lib/utils";
import type { AttendanceRecord } from "@/types/attendance";

export function AttendanceDetailDialog({
  record,
  onClose,
}: {
  record: AttendanceRecord;
  onClose: () => void;
}) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
      <div className="max-h-[90vh] w-full max-w-lg overflow-y-auto rounded-xl border border-slate-200 bg-white p-6 shadow-xl dark:border-slate-800 dark:bg-slate-950">
        <div className="mb-4 flex items-start justify-between gap-4">
          <div>
            <h3 className="text-lg font-semibold">Attendance Detail</h3>
            <p className="text-sm text-slate-500">
              {record.employee.fullName} ({record.employee.employeeCode})
            </p>
          </div>
          <Button variant="outline" size="sm" onClick={onClose}>
            Close
          </Button>
        </div>

        <dl className="space-y-3 text-sm">
          <DetailRow label="Date" value={formatDate(record.attendanceDate)} />
          <DetailRow
            label="Check In"
            value={record.checkIn ? formatDate(record.checkIn) : "—"}
          />
          <DetailRow
            label="Check Out"
            value={record.checkOut ? formatDate(record.checkOut) : "—"}
          />
          <DetailRow label="Working Hours" value={`${record.workingHours}h`} />
          <DetailRow label="Late (min)" value={String(record.lateMinutes)} />
          <DetailRow
            label="Overtime (min)"
            value={String(record.overtimeMinutes)}
          />
          <DetailRow
            label="Break (min)"
            value={String(record.breakDurationMinutes)}
          />
          <DetailRow label="Status" value={record.displayStatus} />
          {record.notes ? (
            <DetailRow label="Notes" value={record.notes} />
          ) : null}
        </dl>
      </div>
    </div>
  );
}

function DetailRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-start justify-between gap-4 border-b border-slate-100 pb-3 dark:border-slate-800">
      <dt className="font-medium text-slate-500">{label}</dt>
      <dd className="text-right text-slate-900 dark:text-slate-100">{value}</dd>
    </div>
  );
}
