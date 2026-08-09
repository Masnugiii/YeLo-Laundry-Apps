import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPatch } from "@/lib/api";
import type {
  AttendanceSettings,
  BackupSettings,
  CompanySettings,
  DocumentRules,
  NotificationSettings,
  DeliverySettingsResponse,
  SettingsSectionUpdateResult,
} from "@/types/settings-config";

export const SETTINGS_CONFIG_KEY = "settings-config";

export function useCompanySettings() {
  return useQuery({
    queryKey: [SETTINGS_CONFIG_KEY, "company"],
    queryFn: () => apiGet<CompanySettings>("/settings/company"),
  });
}

export function useUpdateCompanySettings() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<CompanySettings>) =>
      apiPatch<SettingsSectionUpdateResult<CompanySettings>>(
        "/settings/company",
        input,
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [SETTINGS_CONFIG_KEY, "company"] });
    },
  });
}

export function useAttendanceSettings() {
  return useQuery({
    queryKey: [SETTINGS_CONFIG_KEY, "attendance"],
    queryFn: () => apiGet<AttendanceSettings>("/settings/attendance"),
  });
}

export function useUpdateAttendanceSettings() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<AttendanceSettings>) =>
      apiPatch<SettingsSectionUpdateResult<AttendanceSettings>>(
        "/settings/attendance",
        input,
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: [SETTINGS_CONFIG_KEY, "attendance"],
      });
    },
  });
}

export function useDocumentRules() {
  return useQuery({
    queryKey: [SETTINGS_CONFIG_KEY, "documents"],
    queryFn: () => apiGet<DocumentRules>("/settings/documents"),
  });
}

export function useUpdateDocumentRules() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<DocumentRules>) =>
      apiPatch<SettingsSectionUpdateResult<DocumentRules>>(
        "/settings/documents",
        input,
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: [SETTINGS_CONFIG_KEY, "documents"],
      });
    },
  });
}

export function useNotificationSettings() {
  return useQuery({
    queryKey: [SETTINGS_CONFIG_KEY, "notifications"],
    queryFn: () => apiGet<NotificationSettings>("/settings/notifications"),
  });
}

export function useUpdateNotificationSettings() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: {
      settings?: Partial<NotificationSettings["settings"]>;
      templates?: Array<{
        id: string;
        title?: string;
        body?: string;
        isActive?: boolean;
      }>;
    }) =>
      apiPatch<SettingsSectionUpdateResult<NotificationSettings>>(
        "/settings/notifications",
        input,
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: [SETTINGS_CONFIG_KEY, "notifications"],
      });
    },
  });
}

export function useBackupSettings() {
  return useQuery({
    queryKey: [SETTINGS_CONFIG_KEY, "backup"],
    queryFn: () => apiGet<BackupSettings>("/settings/backup"),
  });
}

export function useUpdateBackupSettings() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<BackupSettings>) =>
      apiPatch<SettingsSectionUpdateResult<BackupSettings>>(
        "/settings/backup",
        input,
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [SETTINGS_CONFIG_KEY, "backup"] });
    },
  });
}

export function useDeliverySettings() {
  return useQuery({
    queryKey: [SETTINGS_CONFIG_KEY, "delivery"],
    queryFn: () => apiGet<DeliverySettingsResponse>("/settings/delivery"),
  });
}
