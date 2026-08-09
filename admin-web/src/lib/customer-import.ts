import * as XLSX from "xlsx";
import type { ImportCustomerRow } from "@/types/customer";

const TEMPLATE_HEADERS = [
  "Full Name",
  "Phone",
  "Email",
  "Gender",
  "Birth Date",
  "Address",
  "Member Status",
];

export function downloadCustomerTemplate() {
  const worksheet = XLSX.utils.aoa_to_sheet([TEMPLATE_HEADERS]);
  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, "Customers");
  XLSX.writeFile(workbook, "customer-import-template.xlsx");
}

function normalizeHeader(value: string) {
  return value.trim().toLowerCase().replace(/\s+/g, " ");
}

function mapRow(record: Record<string, unknown>): ImportCustomerRow | null {
  const entries = Object.entries(record).reduce<Record<string, string>>(
    (acc, [key, value]) => {
      acc[normalizeHeader(key)] = String(value ?? "").trim();
      return acc;
    },
    {},
  );

  const fullName = entries["full name"];
  const phone = entries.phone;
  if (!fullName || !phone) return null;

  return {
    fullName,
    phone,
    email: entries.email || undefined,
    gender: entries.gender || undefined,
    birthDate: entries["birth date"] || undefined,
    address: entries.address || undefined,
    memberStatus: entries["member status"] || undefined,
  };
}

export async function parseCustomerImportFile(file: File) {
  const buffer = await file.arrayBuffer();
  const workbook = XLSX.read(buffer, { type: "array" });
  const sheet = workbook.Sheets[workbook.SheetNames[0]];
  const records = XLSX.utils.sheet_to_json<Record<string, unknown>>(sheet, {
    defval: "",
  });

  const rows = records
    .map(mapRow)
    .filter((row): row is ImportCustomerRow => row !== null);

  const duplicatePhones = rows
    .map((row) => row.phone)
    .filter((phone, index, list) => list.indexOf(phone) !== index);

  return {
    rows,
    duplicatePhones: [...new Set(duplicatePhones)],
  };
}

export function exportCustomersExcel(rows: Record<string, unknown>[]) {
  const worksheet = XLSX.utils.json_to_sheet(rows);
  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, "Customers");
  XLSX.writeFile(workbook, "customers.xlsx");
}
