"use client";

import { Moon, Search, Sun } from "lucide-react";
import { useTheme } from "next-themes";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { clearToken } from "@/lib/api";

export function Topbar({ title }: { title: string }) {
  const { theme, setTheme } = useTheme();
  const router = useRouter();

  return (
    <header className="flex h-16 items-center justify-between border-b border-slate-200 bg-white px-6 dark:border-slate-800 dark:bg-slate-950">
      <div>
        <h1 className="text-lg font-semibold">{title}</h1>
        <p className="text-xs text-slate-500">Yelo Laundry Admin</p>
      </div>
      <div className="flex items-center gap-3">
        <div className="relative hidden md:block">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
          <Input className="w-64 pl-9" placeholder="Search modules..." />
        </div>
        <Button
          variant="outline"
          size="sm"
          onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
        >
          {theme === "dark" ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
        </Button>
        <Button
          variant="outline"
          size="sm"
          onClick={() => {
            clearToken();
            router.push("/login");
          }}
        >
          Logout
        </Button>
      </div>
    </header>
  );
}
