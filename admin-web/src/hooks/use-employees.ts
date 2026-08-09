import {
  useMutation,
  useQuery,
  useQueryClient,
  type QueryKey,
} from "@tanstack/react-query";
import { apiGet, apiPatch, apiPost } from "@/lib/api";
import type { Paginated } from "@/types/api";
import type {
  CreateEmployeeInput,
  Employee,
  EmployeeListParams,
  EmployeeStatistics,
  ResetEmployeePasswordInput,
  UpdateEmployeeInput,
} from "@/types/employee";

export const EMPLOYEES_QUERY_KEY = "employees";

export function employeesQueryKey(params: EmployeeListParams = {}) {
  return [EMPLOYEES_QUERY_KEY, params] as const;
}

export function employeeDetailQueryKey(id: string) {
  return [EMPLOYEES_QUERY_KEY, "detail", id] as const;
}

function updateEmployeeInLists(
  queryClient: ReturnType<typeof useQueryClient>,
  employeeId: string,
  updater: (employee: Employee) => Employee,
) {
  queryClient.setQueriesData<Paginated<Employee>>(
    { queryKey: [EMPLOYEES_QUERY_KEY] },
    (current) => {
      if (!current) return current;
      return {
        ...current,
        items: current.items.map((employee) =>
          employee.id === employeeId ? updater(employee) : employee,
        ),
      };
    },
  );
}

function patchEmployeeCaches(
  queryClient: ReturnType<typeof useQueryClient>,
  employeeId: string,
  patch: Partial<Employee>,
) {
  queryClient.setQueryData<Employee>(employeeDetailQueryKey(employeeId), (current) =>
    current ? { ...current, ...patch, updatedAt: new Date().toISOString() } : current,
  );

  updateEmployeeInLists(queryClient, employeeId, (employee) => ({
    ...employee,
    ...patch,
    updatedAt: new Date().toISOString(),
  }));
}

export function useEmployees(params: EmployeeListParams) {
  return useQuery({
    queryKey: employeesQueryKey(params),
    queryFn: () =>
      apiGet<Paginated<Employee>>(
        "/employees",
        params as Record<string, unknown>,
      ),
  });
}

export function useEmployeeStatistics() {
  return useQuery({
    queryKey: [EMPLOYEES_QUERY_KEY, "statistics"],
    queryFn: () => apiGet<EmployeeStatistics>("/employees/statistics"),
  });
}

export function useEmployee(id: string) {
  return useQuery({
    queryKey: employeeDetailQueryKey(id),
    queryFn: () => apiGet<Employee>(`/employees/${id}`),
    enabled: Boolean(id),
  });
}

export function useCreateEmployee() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: CreateEmployeeInput) =>
      apiPost<Employee>("/employees", input),
    onSuccess: (employee) => {
      queryClient.setQueryData(employeeDetailQueryKey(employee.id), employee);
      queryClient.invalidateQueries({ queryKey: [EMPLOYEES_QUERY_KEY] });
    },
  });
}

export function useUpdateEmployee(id: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: UpdateEmployeeInput) =>
      apiPatch<Employee>(`/employees/${id}`, input),
    onMutate: async (input) => {
      await queryClient.cancelQueries({ queryKey: employeeDetailQueryKey(id) });
      await queryClient.cancelQueries({ queryKey: [EMPLOYEES_QUERY_KEY] });

      const previousDetail = queryClient.getQueryData<Employee>(
        employeeDetailQueryKey(id),
      );
      const previousLists = queryClient.getQueriesData<Paginated<Employee>>({
        queryKey: [EMPLOYEES_QUERY_KEY],
      });

      const definedPatch = Object.fromEntries(
        Object.entries(input).filter(([, value]) => value !== undefined),
      ) as Partial<Employee>;

      patchEmployeeCaches(queryClient, id, definedPatch);

      return { previousDetail, previousLists };
    },
    onError: (_error, _input, context) => {
      if (context?.previousDetail) {
        queryClient.setQueryData(employeeDetailQueryKey(id), context.previousDetail);
      }
      context?.previousLists.forEach(([key, data]) => {
        queryClient.setQueryData(key as QueryKey, data);
      });
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: employeeDetailQueryKey(id) });
      queryClient.invalidateQueries({ queryKey: [EMPLOYEES_QUERY_KEY] });
    },
  });
}

export function useSetEmployeeStatus(id: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (status: UpdateEmployeeInput["status"]) =>
      apiPatch<Employee>(`/employees/${id}`, { status }),
    onMutate: async (status) => {
      await queryClient.cancelQueries({ queryKey: employeeDetailQueryKey(id) });
      await queryClient.cancelQueries({ queryKey: [EMPLOYEES_QUERY_KEY] });

      const previousDetail = queryClient.getQueryData<Employee>(
        employeeDetailQueryKey(id),
      );
      const previousLists = queryClient.getQueriesData<Paginated<Employee>>({
        queryKey: [EMPLOYEES_QUERY_KEY],
      });

      patchEmployeeCaches(queryClient, id, { status });

      return { previousDetail, previousLists };
    },
    onError: (_error, _status, context) => {
      if (context?.previousDetail) {
        queryClient.setQueryData(employeeDetailQueryKey(id), context.previousDetail);
      }
      context?.previousLists.forEach(([key, data]) => {
        queryClient.setQueryData(key as QueryKey, data);
      });
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: employeeDetailQueryKey(id) });
      queryClient.invalidateQueries({ queryKey: [EMPLOYEES_QUERY_KEY] });
    },
  });
}

export function useResetEmployeePassword(id: string) {
  return useMutation({
    mutationFn: (input: ResetEmployeePasswordInput) =>
      apiPost<null>(`/employees/${id}/reset-password`, input),
  });
}
