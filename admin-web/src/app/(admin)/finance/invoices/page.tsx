"use client";

import { ColumnDef } from "@tanstack/react-table";
import { ModuleListPage } from "@/components/module-list-page";

interface InvoiceRow {
  id: string;
  invoiceNumber: string;
  customerName: string;
  totalAmount: number;
  status: string;
  issuedAt: string;
}

const columns: ColumnDef<InvoiceRow, unknown>[] = [
  { accessorKey: "invoiceNumber", header: "Invoice" },
  { accessorKey: "customerName", header: "Customer" },
  { accessorKey: "totalAmount", header: "Total" },
  { accessorKey: "status", header: "Status" },
  { accessorKey: "issuedAt", header: "Issued" },
];

export default function InvoicesPage() {
  return (
    <ModuleListPage<InvoiceRow>
      title="Invoices"
      endpoint="/invoices"
      exportFilename="invoices.csv"
      columns={columns}
    />
  );
}
