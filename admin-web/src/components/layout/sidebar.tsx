"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { adminNav } from "@/config/navigation";
import { cn } from "@/lib/utils";

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="flex h-full w-64 flex-col border-r border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-950">
      <div className="border-b border-slate-200 px-5 py-4 dark:border-slate-800">
        <p className="text-lg font-bold">Yelo Admin</p>
        <p className="text-xs text-slate-500">Business Control Center</p>
      </div>
      <nav className="flex-1 space-y-1 overflow-y-auto p-3">
        {adminNav.map((item) => (
          <div key={item.title}>
            {item.href ? (
              <Link
                href={item.href}
                className={cn(
                  "flex items-center gap-2 rounded-lg px-3 py-2 text-sm hover:bg-slate-100 dark:hover:bg-slate-900",
                  pathname === item.href && "bg-blue-50 text-blue-700 dark:bg-blue-950 dark:text-blue-300",
                )}
              >
                {item.icon ? <item.icon className="h-4 w-4" /> : null}
                {item.title}
              </Link>
            ) : (
              <p className="px-3 py-2 text-xs font-semibold uppercase tracking-wide text-slate-400">
                {item.title}
              </p>
            )}
            {item.children?.map((child) => (
              <Link
                key={child.href}
                href={child.href!}
                className={cn(
                  "ml-2 flex items-center gap-2 rounded-lg px-3 py-2 text-sm hover:bg-slate-100 dark:hover:bg-slate-900",
                  pathname === child.href && "bg-blue-50 text-blue-700 dark:bg-blue-950 dark:text-blue-300",
                )}
              >
                {child.icon ? <child.icon className="h-4 w-4" /> : null}
                {child.title}
              </Link>
            ))}
          </div>
        ))}
      </nav>
    </aside>
  );
}
