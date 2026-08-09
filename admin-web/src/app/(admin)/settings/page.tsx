"use client";

import Link from "next/link";
import { Card, CardTitle } from "@/components/ui/card";

const sections = [
  {
    href: "/settings/company",
    title: "Company Profile",
    description: "Outlet profile, timezone, currency, tax",
  },
  {
    href: "/settings/attendance",
    title: "Attendance",
    description: "Work hours, late tolerance, GPS defaults",
  },
  {
    href: "/settings/documents",
    title: "Document Rules",
    description: "Upload limits and allowed file types",
  },
  {
    href: "/settings/notifications",
    title: "Notifications",
    description: "Outlet toggles and message templates",
  },
  {
    href: "/settings/backup",
    title: "Backup",
    description: "Schedule and retention configuration",
  },
  {
    href: "/settings/delivery",
    title: "Delivery",
    description: "Pickup and delivery configuration status",
  },
  {
    href: "/settings/services",
    title: "Services",
    description: "Laundry service catalog",
  },
  {
    href: "/settings/pricing",
    title: "Pricing",
    description: "Active service prices",
  },
  {
    href: "/settings/numbering",
    title: "Business Numbering",
    description: "ORD, INV, EXP, PAY, CST, EMP",
  },
  {
    href: "/settings/payment-methods",
    title: "Payment Methods",
    description: "Cash, QRIS, transfer, wallet",
  },
  {
    href: "/settings/expense-categories",
    title: "Expense Categories",
    description: "Expense classification master data",
  },
  {
    href: "/settings/loyalty",
    title: "Loyalty",
    description: "Points, membership, vouchers",
  },
  {
    href: "/finance/payroll/settings",
    title: "Payroll Rules",
    description: "Salary calculation settings",
  },
];

export default function SettingsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-semibold">System Settings</h2>
        <p className="text-sm text-slate-500">
          Manage master data and configuration used across ERP modules.
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {sections.map((section) => (
          <Link key={section.href} href={section.href}>
            <Card className="h-full transition hover:border-blue-200 hover:shadow-md">
              <CardTitle>{section.title}</CardTitle>
              <p className="mt-2 text-sm text-slate-500">{section.description}</p>
            </Card>
          </Link>
        ))}
      </div>
    </div>
  );
}
