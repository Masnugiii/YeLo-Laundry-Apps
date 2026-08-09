"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { FormEvent, useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import { useCreateEmployee } from "@/hooks/use-employees";
import { useNumberingConfigurations } from "@/hooks/use-master-data";
import { getErrorMessage } from "@/lib/errors";
import { suggestNextEmployeeCode } from "@/lib/employee-code";
import { EMPLOYEE_STATUSES, type EmployeeStatus } from "@/types/employee";

export default function NewEmployeePage() {
  const router = useRouter();
  const toast = useToast();
  const createEmployee = useCreateEmployee();
  const numberingQuery = useNumberingConfigurations();

  const [form, setForm] = useState({
    employeeCode: "",
    fullName: "",
    phone: "",
    email: "",
    password: "",
    position: "Staff",
    status: "ACTIVE" as EmployeeStatus,
  });

  useEffect(() => {
    const empConfig = numberingQuery.data?.find((item) => item.type === "EMP");
    if (!empConfig || form.employeeCode) return;
    setForm((current) => ({
      ...current,
      employeeCode: suggestNextEmployeeCode(empConfig),
    }));
  }, [form.employeeCode, numberingQuery.data]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      const employee = await createEmployee.mutateAsync({
        employeeCode: form.employeeCode.trim(),
        fullName: form.fullName.trim(),
        phone: form.phone.trim(),
        email: form.email.trim() || undefined,
        password: form.password,
        position: form.position.trim() || undefined,
        status: form.status,
      });
      toast.success("Employee created successfully.");
      router.push(`/operations/employees/${employee.id}`);
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to create employee."));
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <Link
          href="/operations/employees"
          className="text-sm text-blue-600 hover:underline"
        >
          Back to employees
        </Link>
        <h2 className="mt-2 text-2xl font-semibold">Add Employee</h2>
        <p className="text-sm text-slate-500">
          Create a new employee account using the backend employee API.
        </p>
      </div>

      <Card>
        <CardTitle>Employee Information</CardTitle>
        <form className="mt-4 grid gap-4 md:grid-cols-2" onSubmit={handleSubmit}>
          <label className="space-y-2 text-sm">
            <span className="font-medium text-slate-500">Employee Code</span>
            <Input
              value={form.employeeCode}
              onChange={(event) =>
                setForm((current) => ({ ...current, employeeCode: event.target.value }))
              }
              required
            />
          </label>
          <label className="space-y-2 text-sm">
            <span className="font-medium text-slate-500">Full Name</span>
            <Input
              value={form.fullName}
              onChange={(event) =>
                setForm((current) => ({ ...current, fullName: event.target.value }))
              }
              required
            />
          </label>
          <label className="space-y-2 text-sm">
            <span className="font-medium text-slate-500">Phone</span>
            <Input
              value={form.phone}
              onChange={(event) =>
                setForm((current) => ({ ...current, phone: event.target.value }))
              }
              required
            />
          </label>
          <label className="space-y-2 text-sm">
            <span className="font-medium text-slate-500">Email</span>
            <Input
              type="email"
              value={form.email}
              onChange={(event) =>
                setForm((current) => ({ ...current, email: event.target.value }))
              }
            />
          </label>
          <label className="space-y-2 text-sm">
            <span className="font-medium text-slate-500">Position</span>
            <Input
              value={form.position}
              onChange={(event) =>
                setForm((current) => ({ ...current, position: event.target.value }))
              }
            />
          </label>
          <label className="space-y-2 text-sm">
            <span className="font-medium text-slate-500">Status</span>
            <select
              className="h-10 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm outline-none ring-blue-500 focus:ring-2 dark:border-slate-700 dark:bg-slate-900"
              value={form.status}
              onChange={(event) =>
                setForm((current) => ({
                  ...current,
                  status: event.target.value as EmployeeStatus,
                }))
              }
            >
              {EMPLOYEE_STATUSES.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>
          </label>
          <label className="space-y-2 text-sm md:col-span-2">
            <span className="font-medium text-slate-500">Password</span>
            <Input
              type="password"
              value={form.password}
              onChange={(event) =>
                setForm((current) => ({ ...current, password: event.target.value }))
              }
              minLength={6}
              required
            />
          </label>
          <div className="md:col-span-2">
            <Button type="submit" disabled={createEmployee.isPending}>
              {createEmployee.isPending ? "Creating..." : "Create employee"}
            </Button>
          </div>
        </form>
      </Card>
    </div>
  );
}
