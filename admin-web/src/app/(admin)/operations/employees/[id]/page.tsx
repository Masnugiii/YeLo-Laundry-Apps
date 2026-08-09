"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { FormEvent, useState } from "react";
import { EmployeeRoleBadges } from "@/components/employees/employee-role-badges";
import { EmployeeStatusBadge } from "@/components/employees/employee-status-badge";
import {
  EmployeeDetailSkeleton,
  QueryErrorState,
} from "@/components/employees/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { ConfirmDialog } from "@/components/ui/confirm-dialog";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import {
  useEmployee,
  useResetEmployeePassword,
  useSetEmployeeStatus,
  useUpdateEmployee,
} from "@/hooks/use-employees";
import { getErrorMessage } from "@/lib/errors";
import { formatDate } from "@/lib/utils";
import {
  EMPLOYEE_STATUSES,
  type EmployeeStatus,
  type UpdateEmployeeInput,
} from "@/types/employee";

function DetailField({
  label,
  value,
}: {
  label: string;
  value: React.ReactNode;
}) {
  return (
    <div>
      <p className="text-sm font-medium text-slate-500">{label}</p>
      <div className="mt-1 text-sm text-slate-900 dark:text-slate-100">{value}</div>
    </div>
  );
}

function buildFormFromEmployee(
  employee: NonNullable<ReturnType<typeof useEmployee>["data"]>,
): UpdateEmployeeInput {
  return {
    employeeCode: employee.employeeCode,
    fullName: employee.fullName,
    phone: employee.phone,
    email: employee.email ?? "",
    position: employee.position,
    status: employee.status,
  };
}

export default function EmployeeDetailPage() {
  const params = useParams<{ id: string }>();
  const employeeId = params.id;
  const toast = useToast();

  const { data, isLoading, isError, error, refetch } = useEmployee(employeeId);
  const updateEmployee = useUpdateEmployee(employeeId);
  const setEmployeeStatus = useSetEmployeeStatus(employeeId);
  const resetPassword = useResetEmployeePassword(employeeId);

  const [isEditing, setIsEditing] = useState(false);
  const [showDeactivateDialog, setShowDeactivateDialog] = useState(false);
  const [form, setForm] = useState<UpdateEmployeeInput>({});
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  function startEditing() {
    if (!data) return;
    setForm(buildFormFromEmployee(data));
    setIsEditing(true);
  }

  function cancelEditing() {
    setIsEditing(false);
    setForm({});
  }

  if (isLoading) {
    return <EmployeeDetailSkeleton />;
  }

  if (isError || !data) {
    return (
      <QueryErrorState
        title="Failed to load employee"
        message={getErrorMessage(error, "Unable to fetch employee details.")}
        onRetry={() => refetch()}
      />
    );
  }

  const isActive = data.status === "ACTIVE";

  async function handleSave(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    try {
      await updateEmployee.mutateAsync({
        employeeCode: form.employeeCode,
        fullName: form.fullName,
        phone: form.phone,
        email: form.email || undefined,
        position: form.position,
        status: form.status,
      });
      setIsEditing(false);
      setForm({});
      toast.success("Employee updated successfully.");
    } catch (mutationError) {
      toast.error(getErrorMessage(mutationError, "Failed to update employee."));
    }
  }

  async function handleActivate() {
    try {
      await setEmployeeStatus.mutateAsync("ACTIVE");
      toast.success("Employee activated successfully.");
    } catch (mutationError) {
      toast.error(
        getErrorMessage(mutationError, "Failed to activate employee."),
      );
    }
  }

  async function handleDeactivate() {
    try {
      await setEmployeeStatus.mutateAsync("INACTIVE");
      setShowDeactivateDialog(false);
      toast.success("Employee deactivated successfully.");
    } catch (mutationError) {
      toast.error(
        getErrorMessage(mutationError, "Failed to deactivate employee."),
      );
    }
  }

  async function handleResetPassword(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (newPassword !== confirmPassword) {
      toast.error("Password confirmation does not match.");
      return;
    }

    try {
      await resetPassword.mutateAsync({ newPassword });
      setNewPassword("");
      setConfirmPassword("");
      toast.success("Password reset successfully.");
    } catch (mutationError) {
      toast.error(getErrorMessage(mutationError, "Failed to reset password."));
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <Link
            href="/operations/employees"
            className="text-sm text-blue-600 hover:underline"
          >
            Back to employees
          </Link>
          <h2 className="mt-2 text-2xl font-semibold">{data.fullName}</h2>
          <p className="text-sm text-slate-500">{data.employeeCode}</p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button variant="outline" onClick={() => (isEditing ? cancelEditing() : startEditing())}>
            {isEditing ? "Cancel edit" : "Edit employee"}
          </Button>
          {isActive ? (
            <Button
              variant="destructive"
              disabled={setEmployeeStatus.isPending}
              onClick={() => setShowDeactivateDialog(true)}
            >
              Deactivate
            </Button>
          ) : (
            <Button
              disabled={setEmployeeStatus.isPending}
              onClick={handleActivate}
            >
              Activate
            </Button>
          )}
        </div>
      </div>

      {isEditing ? (
        <Card>
          <CardTitle>Edit Employee</CardTitle>
          <form className="mt-4 grid gap-4 md:grid-cols-2" onSubmit={handleSave}>
            <label className="space-y-2 text-sm">
              <span className="font-medium text-slate-500">Employee Code</span>
              <Input
                value={form.employeeCode ?? ""}
                onChange={(event) =>
                  setForm((current) => ({ ...current, employeeCode: event.target.value }))
                }
                required
              />
            </label>
            <label className="space-y-2 text-sm">
              <span className="font-medium text-slate-500">Full Name</span>
              <Input
                value={form.fullName ?? ""}
                onChange={(event) =>
                  setForm((current) => ({ ...current, fullName: event.target.value }))
                }
                required
              />
            </label>
            <label className="space-y-2 text-sm">
              <span className="font-medium text-slate-500">Phone</span>
              <Input
                value={form.phone ?? ""}
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
                value={form.email ?? ""}
                onChange={(event) =>
                  setForm((current) => ({ ...current, email: event.target.value }))
                }
              />
            </label>
            <label className="space-y-2 text-sm">
              <span className="font-medium text-slate-500">Position</span>
              <Input
                value={form.position ?? ""}
                onChange={(event) =>
                  setForm((current) => ({ ...current, position: event.target.value }))
                }
              />
            </label>
            <label className="space-y-2 text-sm">
              <span className="font-medium text-slate-500">Status</span>
              <select
                className="h-10 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm outline-none ring-blue-500 focus:ring-2 dark:border-slate-700 dark:bg-slate-900"
                value={form.status ?? "ACTIVE"}
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
            <div className="md:col-span-2">
              <Button type="submit" disabled={updateEmployee.isPending}>
                {updateEmployee.isPending ? "Saving..." : "Save changes"}
              </Button>
            </div>
          </form>
        </Card>
      ) : (
        <Card>
          <CardTitle>Employee Details</CardTitle>
          <div className="mt-4 grid gap-4 md:grid-cols-2">
            <DetailField label="Employee Code" value={data.employeeCode} />
            <DetailField label="Full Name" value={data.fullName} />
            <DetailField label="Phone" value={data.phone} />
            <DetailField label="Email" value={data.email ?? "-"} />
            <DetailField label="Position" value={data.position} />
            <DetailField
              label="Status"
              value={<EmployeeStatusBadge status={data.status} />}
            />
            <DetailField
              label="Roles"
              value={<EmployeeRoleBadges roles={data.roles} />}
            />
            <DetailField
              label="Last Login"
              value={data.lastLoginAt ? formatDate(data.lastLoginAt) : "Never"}
            />
            <DetailField
              label="Created Date"
              value={formatDate(data.createdAt)}
            />
            <DetailField
              label="Updated Date"
              value={formatDate(data.updatedAt)}
            />
          </div>
        </Card>
      )}

      <Card>
        <CardTitle>Reset Password</CardTitle>
        <form className="mt-4 grid gap-4 md:max-w-xl" onSubmit={handleResetPassword}>
          <label className="space-y-2 text-sm">
            <span className="font-medium text-slate-500">New Password</span>
            <Input
              type="password"
              value={newPassword}
              onChange={(event) => setNewPassword(event.target.value)}
              minLength={8}
              required
            />
          </label>
          <label className="space-y-2 text-sm">
            <span className="font-medium text-slate-500">Confirm Password</span>
            <Input
              type="password"
              value={confirmPassword}
              onChange={(event) => setConfirmPassword(event.target.value)}
              minLength={8}
              required
            />
          </label>
          <p className="text-xs text-slate-500">
            Password must be at least 8 characters and include uppercase, lowercase,
            number, and special character.
          </p>
          <Button type="submit" variant="outline" disabled={resetPassword.isPending}>
            {resetPassword.isPending ? "Resetting..." : "Reset password"}
          </Button>
        </form>
      </Card>

      <ConfirmDialog
        open={showDeactivateDialog}
        title="Deactivate employee?"
        description={`Are you sure you want to deactivate ${data.fullName}? They will no longer be able to access the system.`}
        confirmLabel="Deactivate"
        destructive
        loading={setEmployeeStatus.isPending}
        onConfirm={handleDeactivate}
        onCancel={() => setShowDeactivateDialog(false)}
      />
    </div>
  );
}
