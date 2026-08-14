import {
  useMutation,
  useQuery,
  useQueryClient,
} from "@tanstack/react-query";
import { apiGet, apiPost } from "@/lib/api";
import type {
  AssignRolePermissionsInput,
  InternalRoleRecord,
  PermissionRecord,
} from "@/types/internal-access";

export const INTERNAL_ACCESS_QUERY_KEY = "internal-access";

export function useInternalRoles(enabled = true) {
  return useQuery({
    queryKey: [INTERNAL_ACCESS_QUERY_KEY, "roles"],
    enabled,
    queryFn: () => apiGet<InternalRoleRecord[]>("/roles"),
  });
}

export function usePermissionsCatalog(enabled = true) {
  return useQuery({
    queryKey: [INTERNAL_ACCESS_QUERY_KEY, "permissions"],
    enabled,
    queryFn: () => apiGet<PermissionRecord[]>("/permissions"),
  });
}

export function useRolePermissions(roleId?: string) {
  return useQuery({
    queryKey: [INTERNAL_ACCESS_QUERY_KEY, "role-permissions", roleId],
    enabled: Boolean(roleId),
    queryFn: () =>
      apiGet<PermissionRecord[]>(`/roles/${roleId}/permissions`),
  });
}

export function useAssignRolePermissions() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ roleId, permissionIds }: AssignRolePermissionsInput) =>
      apiPost<PermissionRecord[]>(`/roles/${roleId}/permissions`, {
        permissionIds,
      }),
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({
        queryKey: [
          INTERNAL_ACCESS_QUERY_KEY,
          "role-permissions",
          variables.roleId,
        ],
      });
    },
  });
}
