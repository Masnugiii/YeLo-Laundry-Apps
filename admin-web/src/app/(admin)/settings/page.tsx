"use client";

import Link from "next/link";
import { Card, CardTitle } from "@/components/ui/card";
import { isDevToolsEnabled } from "@/lib/env";

const sections = [
  {
    href: "/settings/internal-access",
    title: "Internal Access",
    description: "Role-based menu access for the Internal App",
  },
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
    description: "Laundry service catalog and pricing",
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
    href: "/settings/payment",
    title: "Payment",
    description: "Customer app QRIS and bank transfer configuration",
  },
  {
    href: "/settings/promo",
    title: "Promo",
    description: "Customer app promo percentage badges and voucher rules",
  },
  {
    href: "/settings/perfumes",
    title: "Perfume",
    description: "Laundry perfume options for customer checkout",
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
    title: "YeLo Rewards",
    description: "Point rules, deposit rules, membership, cashback, reward catalog",
  },
  {
    href: "/finance/payroll/settings",
    title: "Payroll Rules",
    description: "Salary calculation settings",
  },
];

const devSections = isDevToolsEnabled()
  ? [
      {
        href: "/settings/development-tools",
        title: "Development Tools",
        description: "Local-only OTP testing utilities for Customer App",
      },
    ]
  : [];

const allSections = [...sections, ...devSections];

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
        {allSections.map((section) => (
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
