import {
  BarChart3,
  Bell,
  ClipboardList,
  CreditCard,
  FileText,
  LayoutDashboard,
  Package,
  Settings,
  Shirt,
  TrendingUp,
  Truck,
  Users,
  Wallet,
} from "lucide-react";

export interface NavItem {
  title: string;
  href?: string;
  icon?: React.ComponentType<{ className?: string }>;
  children?: NavItem[];
}

export const adminNav: NavItem[] = [
  { title: "Dashboard", href: "/", icon: LayoutDashboard },
  {
    title: "Operations",
    icon: Package,
    children: [
      { title: "Employees", href: "/operations/employees", icon: Users },
      { title: "Customers", href: "/operations/customers", icon: Users },
      { title: "Yelo Wallet", href: "/operations/customers/wallet", icon: Wallet },
      { title: "Orders", href: "/operations/orders", icon: ClipboardList },
      { title: "Laundry Production", href: "/operations/production", icon: Shirt },
      { title: "Pickup & Delivery", href: "/operations/pickup-delivery", icon: Truck },
    ],
  },
  {
    title: "Finance",
    icon: Wallet,
    children: [
      { title: "Finance Dashboard", href: "/finance/dashboard", icon: LayoutDashboard },
      { title: "Revenue", href: "/finance/revenue", icon: CreditCard },
      { title: "Expenses", href: "/finance/expenses", icon: FileText },
      { title: "Payroll", href: "/finance/payroll", icon: Users },
      { title: "Profit & Loss", href: "/finance/profit-loss", icon: BarChart3 },
      { title: "Cash Flow", href: "/finance/cash-flow", icon: Wallet },
      { title: "Invoices", href: "/finance/invoices", icon: FileText },
    ],
  },
  {
    title: "Business Intelligence",
    icon: BarChart3,
    children: [
      { title: "Executive Dashboard", href: "/bi/executive", icon: LayoutDashboard },
      { title: "Sales Report", href: "/bi/sales", icon: CreditCard },
      { title: "Customer Analytics", href: "/bi/customers", icon: Users },
      { title: "Production Analytics", href: "/bi/production", icon: Shirt },
      { title: "Employee Performance", href: "/bi/employees", icon: Users },
      { title: "Finance Analytics", href: "/bi/finance", icon: Wallet },
      { title: "Payroll Analytics", href: "/bi/payroll", icon: FileText },
      { title: "Wallet Analytics", href: "/bi/wallet", icon: Wallet },
      { title: "Membership Analytics", href: "/bi/membership", icon: TrendingUp },
      { title: "Forecast", href: "/bi/forecast", icon: TrendingUp },
      { title: "Export Center", href: "/bi/export", icon: FileText },
    ],
  },
  { title: "Reports", href: "/reports", icon: FileText },
  { title: "Analytics", href: "/analytics", icon: BarChart3 },
  { title: "Audit Log", href: "/audit-log", icon: ClipboardList },
  { title: "Notifications", href: "/notifications", icon: Bell },
  { title: "Settings", href: "/settings", icon: Settings },
];
