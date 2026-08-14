import type { QueryKey } from "@tanstack/react-query";
import type { Paginated } from "../types/api";
import type { Employee, EmployeeListParams } from "../types/employee";

export const EMPLOYEES_QUERY_KEY = "employees";

export function employeesQueryKey(params: EmployeeListParams = {}) {
  return [EMPLOYEES_QUERY_KEY, params] as const;
}

export function employeeDetailQueryKey(id: string) {
  return [EMPLOYEES_QUERY_KEY, "detail", id] as const;
}

export function isEmployeeListQueryKey(queryKey: QueryKey): boolean {
  if (queryKey[0] !== EMPLOYEES_QUERY_KEY) {
    return false;
  }

  if (queryKey.length !== 2) {
    return false;
  }

  const params = queryKey[1];
  return typeof params === "object" && params !== null && !Array.isArray(params);
}

export function isPaginatedEmployeeList(
  value: unknown,
): value is Paginated<Employee> {
  if (typeof value !== "object" || value === null) {
    return false;
  }

  const candidate = value as Paginated<Employee>;
  return (
    Array.isArray(candidate.items) &&
    typeof candidate.meta === "object" &&
    candidate.meta !== null
  );
}

export function patchEmployeeListItems(
  current: unknown,
  employeeId: string,
  updater: (employee: Employee) => Employee,
): unknown {
  if (!isPaginatedEmployeeList(current)) {
    return current;
  }

  return {
    ...current,
    items: current.items.map((employee) =>
      employee.id === employeeId ? updater(employee) : employee,
    ),
  };
}
