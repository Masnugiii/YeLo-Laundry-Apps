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
import {
  EMPLOYEES_QUERY_KEY,
  employeeDetailQueryKey,
  employeesQueryKey,
  isEmployeeListQueryKey,
  patchEmployeeListItems,
} from "@/hooks/employee-query-cache";

export { EMPLOYEES_QUERY_KEY, employeeDetailQueryKey, employeesQueryKey };

function updateEmployeeInLists(
  queryClient: ReturnType<typeof useQueryClient>,
  employeeId: string,
  updater: (employee: Employee) => Employee,
) {
  queryClient.setQueriesData(
    {
      queryKey: [EMPLOYEES_QUERY_KEY],
      predicate: (query) => isEmployeeListQueryKey(query.queryKey),
    },
    (current) => patchEmployeeListItems(current, employeeId, updater),
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
      await queryClient.cancelQueries({
        queryKey: [EMPLOYEES_QUERY_KEY],
        predicate: (query) => isEmployeeListQueryKey(query.queryKey),
      });

      const previousDetail = queryClient.getQueryData<Employee>(
        employeeDetailQueryKey(id),
      );
      const previousLists = queryClient.getQueriesData<Paginated<Employee>>({
        queryKey: [EMPLOYEES_QUERY_KEY],
        predicate: (query) => isEmployeeListQueryKey(query.queryKey),
      });

      const definedPatch = Object.fromEntries(
        Object.entries(input).filter(([, value]) => value !== undefined),
      ) as Partial<Employee>;

      patchEmployeeCaches(queryClient, id, definedPatch);

      return { previousDetail, previousLists };
    },
    onSuccess: (employee) => {
      queryClient.setQueryData(employeeDetailQueryKey(id), employee);
      updateEmployeeInLists(queryClient, id, () => employee);
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
      queryClient.invalidateQueries({
        queryKey: [EMPLOYEES_QUERY_KEY],
        predicate: (query) => isEmployeeListQueryKey(query.queryKey),
      });
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
      await queryClient.cancelQueries({
        queryKey: [EMPLOYEES_QUERY_KEY],
        predicate: (query) => isEmployeeListQueryKey(query.queryKey),
      });

      const previousDetail = queryClient.getQueryData<Employee>(
        employeeDetailQueryKey(id),
      );
      const previousLists = queryClient.getQueriesData<Paginated<Employee>>({
        queryKey: [EMPLOYEES_QUERY_KEY],
        predicate: (query) => isEmployeeListQueryKey(query.queryKey),
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
      queryClient.invalidateQueries({
        queryKey: [EMPLOYEES_QUERY_KEY],
        predicate: (query) => isEmployeeListQueryKey(query.queryKey),
      });
    },
  });
}

export function useResetEmployeePassword(id: string) {
  return useMutation({
    mutationFn: (input: ResetEmployeePasswordInput) =>
      apiPost<null>(`/employees/${id}/reset-password`, input),
  });
}
