"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { Card, CardTitle } from "@/components/ui/card";
import { isDevToolsEnabled } from "@/lib/env";
import { isOwnerRole } from "@/lib/auth";

const sections = [
  {
    href: "/settings/development-tools/otp-testing",
    title: "OTP Testing",
    description: "Generate development OTP codes for Customer App login testing",
  },
];

export default function DevelopmentToolsPage() {
  const router = useRouter();
  const canAccess = isOwnerRole() && isDevToolsEnabled();

  useEffect(() => {
    if (!canAccess) {
      router.replace("/settings");
    }
  }, [canAccess, router]);

  if (!canAccess) {
    return null;
  }

  return (
    <div className="space-y-6">
      <div>
        <Link href="/settings" className="text-sm text-blue-600">
          ← Back to Settings
        </Link>
        <h2 className="mt-2 text-xl font-semibold">Development Tools</h2>
        <p className="text-sm text-slate-500">
          Local-only utilities for integration testing. Not available in production.
        </p>
      </div>

      <div className="rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900">
        Development only — jangan digunakan untuk production.
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
