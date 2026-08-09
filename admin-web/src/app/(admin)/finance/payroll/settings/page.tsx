import Link from "next/link";
import { PayrollSettingsForm } from "@/components/payroll/settings-form";
import { Button } from "@/components/ui/button";

export default function PayrollSettingsPage() {
  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <Link href="/finance/payroll" className="text-sm text-blue-600 hover:underline">
            ← Back to Payroll
          </Link>
          <h2 className="mt-2 text-xl font-semibold">Payroll Configuration</h2>
          <p className="text-sm text-slate-500">
            Manage salary rules and payroll schedule used by the payroll engine.
          </p>
        </div>
        <Link href="/finance/payroll">
          <Button variant="outline">Payroll Dashboard</Button>
        </Link>
      </div>
      <PayrollSettingsForm />
    </div>
  );
}
