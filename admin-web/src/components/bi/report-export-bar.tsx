"use client";

import {
  exportRowsCsv,
  exportRowsExcel,
  printFinanceReport,
} from "@/lib/finance-export";
import { Button } from "@/components/ui/button";

export function ReportExportBar({
  filename,
  title,
  rows,
}: {
  filename: string;
  title: string;
  rows: Array<Record<string, string | number>>;
}) {
  return (
    <div className="flex flex-wrap gap-2">
      <Button
        variant="outline"
        disabled={!rows.length}
        onClick={() => exportRowsCsv(`${filename}.csv`, rows)}
      >
        CSV
      </Button>
      <Button
        variant="outline"
        disabled={!rows.length}
        onClick={() => exportRowsExcel(`${filename}.xlsx`, rows)}
      >
        Excel
      </Button>
      <Button
        variant="outline"
        disabled={!rows.length}
        onClick={() => printFinanceReport(title, rows)}
      >
        PDF / Print
      </Button>
    </div>
  );
}
