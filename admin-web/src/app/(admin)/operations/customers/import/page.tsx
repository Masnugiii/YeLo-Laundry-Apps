"use client";

import Link from "next/link";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { useToast } from "@/components/ui/toast";
import { useImportCustomers } from "@/hooks/use-customers";
import { getErrorMessage } from "@/lib/errors";
import {
  downloadCustomerTemplate,
  parseCustomerImportFile,
} from "@/lib/customer-import";
import type {
  CustomerImportResult,
  DuplicateImportStrategy,
  ImportCustomerRow,
} from "@/types/customer";

type ImportStep = "upload" | "preview" | "result";

export default function ImportCustomersPage() {
  const toast = useToast();
  const importCustomers = useImportCustomers();

  const [step, setStep] = useState<ImportStep>("upload");
  const [rows, setRows] = useState<ImportCustomerRow[]>([]);
  const [duplicateStrategy, setDuplicateStrategy] =
    useState<DuplicateImportStrategy>("SKIP");
  const [result, setResult] = useState<CustomerImportResult | null>(null);
  const [parseError, setParseError] = useState<string | null>(null);

  async function handleFileChange(file: File | null) {
    if (!file) return;
    setParseError(null);
    try {
      const parsed = await parseCustomerImportFile(file);
      if (!parsed.rows.length) {
        setParseError("No valid rows found in the uploaded file.");
        return;
      }
      setRows(parsed.rows);
      setStep("preview");
    } catch (error) {
      setParseError(getErrorMessage(error, "Failed to parse import file."));
    }
  }

  async function handleImport() {
    try {
      const importResult = await importCustomers.mutateAsync({
        duplicateStrategy,
        rows,
      });
      setResult(importResult);
      setStep("result");
      toast.success("Customer import completed.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Customer import failed."));
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <Link href="/operations/customers" className="text-sm text-blue-600 hover:underline">
            Back to customers
          </Link>
          <h2 className="mt-2 text-2xl font-semibold">Import Customers</h2>
        </div>
        <Button variant="outline" onClick={downloadCustomerTemplate}>
          Download Template
        </Button>
      </div>

      {step === "upload" ? (
        <Card>
          <CardTitle>Upload File</CardTitle>
          <div className="mt-4 space-y-4">
            <p className="text-sm text-slate-500">
              Supported formats: `.xlsx`, `.csv`
            </p>
            <input
              type="file"
              accept=".xlsx,.csv"
              onChange={(event) => handleFileChange(event.target.files?.[0] ?? null)}
            />
            {parseError ? <p className="text-sm text-red-600">{parseError}</p> : null}
          </div>
        </Card>
      ) : null}

      {step === "preview" ? (
        <Card>
          <CardTitle>Preview Import</CardTitle>
          <div className="mt-4 space-y-4">
            <label className="block text-sm">
              <span className="font-medium text-slate-500">Duplicate strategy</span>
              <select
                className="mt-2 h-10 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
                value={duplicateStrategy}
                onChange={(event) =>
                  setDuplicateStrategy(event.target.value as DuplicateImportStrategy)
                }
              >
                <option value="SKIP">Skip duplicate</option>
                <option value="UPDATE">Update existing customer</option>
                <option value="CANCEL">Cancel import</option>
              </select>
            </label>
            <div className="overflow-x-auto rounded-lg border border-slate-200 dark:border-slate-800">
              <table className="min-w-full text-sm">
                <thead>
                  <tr className="text-left text-slate-500">
                    <th className="px-3 py-2">Full Name</th>
                    <th className="px-3 py-2">Phone</th>
                    <th className="px-3 py-2">Email</th>
                    <th className="px-3 py-2">Member Status</th>
                  </tr>
                </thead>
                <tbody>
                  {rows.slice(0, 10).map((row, index) => (
                    <tr key={`${row.phone}-${index}`} className="border-t border-slate-100 dark:border-slate-800">
                      <td className="px-3 py-2">{row.fullName}</td>
                      <td className="px-3 py-2">{row.phone}</td>
                      <td className="px-3 py-2">{row.email ?? "-"}</td>
                      <td className="px-3 py-2">{row.memberStatus ?? "REGULAR"}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <p className="text-sm text-slate-500">
              Showing {Math.min(rows.length, 10)} of {rows.length} rows
            </p>
            <div className="flex gap-2">
              <Button variant="outline" onClick={() => setStep("upload")}>
                Back
              </Button>
              <Button onClick={handleImport} disabled={importCustomers.isPending}>
                {importCustomers.isPending ? "Importing..." : "Import"}
              </Button>
            </div>
          </div>
        </Card>
      ) : null}

      {step === "result" && result ? (
        <Card>
          <CardTitle>Import Result</CardTitle>
          <div className="mt-4 grid gap-4 sm:grid-cols-3">
            <div className="rounded-lg border border-emerald-200 bg-emerald-50 p-4 dark:border-emerald-900 dark:bg-emerald-950">
              <p className="text-sm text-slate-500">Imported</p>
              <p className="text-2xl font-semibold">{result.imported}</p>
            </div>
            <div className="rounded-lg border border-amber-200 bg-amber-50 p-4 dark:border-amber-900 dark:bg-amber-950">
              <p className="text-sm text-slate-500">Duplicate</p>
              <p className="text-2xl font-semibold">{result.duplicate}</p>
            </div>
            <div className="rounded-lg border border-red-200 bg-red-50 p-4 dark:border-red-900 dark:bg-red-950">
              <p className="text-sm text-slate-500">Failed</p>
              <p className="text-2xl font-semibold">{result.failed}</p>
            </div>
          </div>
          {result.errors.length ? (
            <div className="mt-4 space-y-2">
              {result.errors.map((error) => (
                <p key={`${error.row}-${error.phone}`} className="text-sm text-red-600">
                  Row {error.row} ({error.phone}): {error.message}
                </p>
              ))}
            </div>
          ) : null}
          <div className="mt-6">
            <Link href="/operations/customers">
              <Button>Back to customers</Button>
            </Link>
          </div>
        </Card>
      ) : null}
    </div>
  );
}
