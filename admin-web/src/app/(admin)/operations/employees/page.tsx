"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { EmployeeRoleBadges } from "@/components/employees/employee-role-badges";
import { EmployeeStatisticsCards } from "@/components/employees/employee-statistics-cards";
import { EmployeeStatusBadge } from "@/components/employees/employee-status-badge";
import {
  EmptyState,
  EmployeeListSkeleton,
  QueryErrorState,
} from "@/components/employees/list-states";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useEmployees, useEmployeeStatistics } from "@/hooks/use-employees";
import { getErrorMessage } from "@/lib/errors";
import { formatDate } from "@/lib/utils";
import {
  EMPLOYEE_ROLES,
  EMPLOYEE_STATUSES,
  type EmployeeListParams,
  type EmployeeRole,
  type EmployeeStatus,
} from "@/types/employee";

const PAGE_SIZE = 20;

export default function EmployeesPage() {
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [role, setRole] = useState<EmployeeRole | "">("");
  const [status, setStatus] = useState<EmployeeStatus | "">("");
  const [page, setPage] = useState(1);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setSearch(searchInput.trim());
      setPage(1);
    }, 300);

    return () => window.clearTimeout(timer);
  }, [searchInput]);

  const params: EmployeeListParams = {
    page,
    limit: PAGE_SIZE,
    sortBy: "createdAt",
    sortOrder: "desc",
    ...(search ? { search } : {}),
    ...(role ? { role } : {}),
    ...(status ? { status } : {}),
  };

  const { data, isLoading, isError, error, refetch } = useEmployees(params);
  const statisticsQuery = useEmployeeStatistics();

  if (isLoading) {
    return <EmployeeListSkeleton />;
  }

  if (isError) {
    return (
      <QueryErrorState
        title="Failed to load employees"
        message={getErrorMessage(error, "Unable to fetch employees from the server.")}
        onRetry={() => refetch()}
      />
    );
  }

  const employees = data?.items ?? [];
  const meta = data?.meta;
  const hasFilters = Boolean(search || role || status);

  return (
    <div className="space-y-4">
      {statisticsQuery.data ? (
        <EmployeeStatisticsCards data={statisticsQuery.data} />
      ) : null}

      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="grid flex-1 gap-3 md:grid-cols-4">
          <Input
            className="md:col-span-2"
            placeholder="Search by code, name, phone, or email"
            value={searchInput}
            onChange={(event) => setSearchInput(event.target.value)}
          />
          <select
            className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm outline-none ring-blue-500 focus:ring-2 dark:border-slate-700 dark:bg-slate-900"
            value={role}
            onChange={(event) => {
              setRole(event.target.value as EmployeeRole | "");
              setPage(1);
            }}
          >
            <option value="">All roles</option>
            {EMPLOYEE_ROLES.map((item) => (
              <option key={item} value={item}>
                {item}
              </option>
            ))}
          </select>
          <select
            className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm outline-none ring-blue-500 focus:ring-2 dark:border-slate-700 dark:bg-slate-900"
            value={status}
            onChange={(event) => {
              setStatus(event.target.value as EmployeeStatus | "");
              setPage(1);
            }}
          >
            <option value="">All statuses</option>
            {EMPLOYEE_STATUSES.map((item) => (
              <option key={item} value={item}>
                {item}
              </option>
            ))}
          </select>
        </div>
        <Link href="/operations/employees/new">
          <Button className="w-full sm:w-auto">Add Employee</Button>
        </Link>
      </div>

      {employees.length === 0 ? (
        <EmptyState
          title="No employees found"
          description={
            hasFilters
              ? "Try adjusting your search or filters to find employees."
              : "There are no employees in the system yet."
          }
          action={
            !hasFilters ? (
              <Link href="/operations/employees/new">
                <Button>Add Employee</Button>
              </Link>
            ) : undefined
          }
        />
      ) : (
        <>
          <div className="hidden overflow-x-auto rounded-xl border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900 md:block">
            <table className="min-w-full text-sm">
              <thead className="bg-slate-50 dark:bg-slate-900">
                <tr>
                  <th className="px-4 py-3 text-left font-medium text-slate-500">Code</th>
                  <th className="px-4 py-3 text-left font-medium text-slate-500">Name</th>
                  <th className="px-4 py-3 text-left font-medium text-slate-500">Phone</th>
                  <th className="px-4 py-3 text-left font-medium text-slate-500">Position</th>
                  <th className="px-4 py-3 text-left font-medium text-slate-500">Roles</th>
                  <th className="px-4 py-3 text-left font-medium text-slate-500">Status</th>
                  <th className="px-4 py-3 text-left font-medium text-slate-500">Last Login</th>
                  <th className="px-4 py-3 text-right font-medium text-slate-500">Action</th>
                </tr>
              </thead>
              <tbody>
                {employees.map((employee) => (
                  <tr
                    key={employee.id}
                    className="border-t border-slate-100 dark:border-slate-800"
                  >
                    <td className="px-4 py-3 font-medium">{employee.employeeCode}</td>
                    <td className="px-4 py-3">{employee.fullName}</td>
                    <td className="px-4 py-3">{employee.phone}</td>
                    <td className="px-4 py-3">{employee.position}</td>
                    <td className="px-4 py-3">
                      <EmployeeRoleBadges roles={employee.roles} />
                    </td>
                    <td className="px-4 py-3">
                      <EmployeeStatusBadge status={employee.status} />
                    </td>
                    <td className="px-4 py-3 text-slate-500">
                      {employee.lastLoginAt ? formatDate(employee.lastLoginAt) : "Never"}
                    </td>
                    <td className="px-4 py-3 text-right">
                      <Link href={`/operations/employees/${employee.id}`}>
                        <Button variant="outline" size="sm">
                          View
                        </Button>
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="space-y-3 md:hidden">
            {employees.map((employee) => (
              <Link
                key={employee.id}
                href={`/operations/employees/${employee.id}`}
                className="block rounded-xl border border-slate-200 bg-white p-4 dark:border-slate-800 dark:bg-slate-900"
              >
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="font-semibold">{employee.fullName}</p>
                    <p className="text-sm text-slate-500">{employee.employeeCode}</p>
                  </div>
                  <EmployeeStatusBadge status={employee.status} />
                </div>
                <div className="mt-3 space-y-2 text-sm text-slate-600 dark:text-slate-300">
                  <p>{employee.phone}</p>
                  <p>{employee.position}</p>
                  <EmployeeRoleBadges roles={employee.roles} />
                  <p className="text-slate-500">
                    Last login:{" "}
                    {employee.lastLoginAt ? formatDate(employee.lastLoginAt) : "Never"}
                  </p>
                </div>
              </Link>
            ))}
          </div>

          {meta ? (
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-sm text-slate-500">
                Showing {(meta.page - 1) * meta.limit + 1}-
                {Math.min(meta.page * meta.limit, meta.total)} of {meta.total} employees
              </p>
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={page <= 1}
                  onClick={() => setPage((current) => current - 1)}
                >
                  Previous
                </Button>
                <span className="flex items-center px-2 text-sm text-slate-500">
                  Page {meta.page} of {meta.totalPages}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={page >= meta.totalPages}
                  onClick={() => setPage((current) => current + 1)}
                >
                  Next
                </Button>
              </div>
            </div>
          ) : null}
        </>
      )}
    </div>
  );
}
