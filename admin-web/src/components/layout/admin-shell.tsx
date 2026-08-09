"use client";

import { usePathname, useRouter } from "next/navigation";
import { useEffect } from "react";
import { Sidebar } from "@/components/layout/sidebar";
import { Topbar } from "@/components/layout/topbar";
import { getStoredToken } from "@/lib/api";

const titleMap: Record<string, string> = {
  "/": "Dashboard",
  "/operations/employees": "Employees",
  "/operations/customers": "Customers",
  "/operations/customers/wallet": "Yelo Wallet",
  "/operations/orders": "Orders",
  "/operations/production": "Production Management",
  "/operations/laundry": "Laundry Production",
  "/operations/pickup-delivery": "Pickup & Delivery",
  "/finance/dashboard": "Finance Dashboard",
  "/finance/revenue": "Revenue",
  "/finance/expenses": "Expenses",
  "/finance/payroll": "Payroll",
  "/finance/payroll/settings": "Payroll Settings",
  "/finance/profit-loss": "Profit & Loss",
  "/finance/cash-flow": "Cash Flow",
  "/finance/invoices": "Invoices",
  "/reports": "Reports",
  "/bi/executive": "Executive Dashboard",
  "/bi/sales": "Sales Report",
  "/bi/customers": "Customer Analytics",
  "/bi/production": "Production Analytics",
  "/bi/employees": "Employee Performance",
  "/bi/finance": "Finance Analytics",
  "/bi/payroll": "Payroll Analytics",
  "/bi/wallet": "Wallet Analytics",
  "/bi/membership": "Membership Analytics",
  "/bi/forecast": "Forecast",
  "/bi/export": "Export Center",
  "/analytics": "Analytics",
  "/audit-log": "Audit Log",
  "/notifications": "Notifications",
  "/settings": "Settings",
  "/settings/loyalty": "Loyalty Settings",
};

export function AdminShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();

  useEffect(() => {
    if (!getStoredToken()) {
      router.replace("/login");
    }
  }, [router]);

  return (
    <div className="flex min-h-screen bg-slate-50 dark:bg-slate-950">
      <Sidebar />
      <div className="flex min-h-screen flex-1 flex-col">
        <Topbar
          title={
            pathname.startsWith("/operations/orders/") &&
            pathname !== "/operations/orders"
              ? "Order Detail"
              : pathname === "/operations/customers/new"
              ? "Add Customer"
              : pathname === "/operations/customers/import"
                ? "Import Customers"
                : pathname.startsWith("/operations/customers/") &&
                    pathname !== "/operations/customers"
                  ? "Customer Detail"
                  : pathname === "/operations/employees/new"
                    ? "Add Employee"
                    : pathname.startsWith("/operations/employees/") &&
                        pathname !== "/operations/employees"
                      ? "Employee Detail"
                      : pathname.startsWith("/operations/production/") &&
                          pathname !== "/operations/production"
                        ? "Production Detail"
                        : pathname.startsWith("/finance/payroll/") &&
                            pathname !== "/finance/payroll" &&
                            pathname !== "/finance/payroll/settings"
                          ? "Payroll Detail"
                          : (titleMap[pathname] ?? "Admin")
          }
        />
        <main className="flex-1 p-6">{children}</main>
      </div>
    </div>
  );
}
