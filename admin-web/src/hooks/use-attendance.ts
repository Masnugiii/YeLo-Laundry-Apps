import { useQuery } from "@tanstack/react-query";
import { apiGet } from "@/lib/api";
import type { Paginated } from "@/types/api";
import type {
  AttendanceDashboard,
  AttendanceListParams,
  AttendanceRecord,
} from "@/types/attendance";

export const ATTENDANCE_QUERY_KEY = "attendance";

export function useAttendanceDashboard() {
  return useQuery({
    queryKey: [ATTENDANCE_QUERY_KEY, "dashboard"],
    queryFn: () => apiGet<AttendanceDashboard>("/attendance/dashboard"),
  });
}

export function useAttendance(params: AttendanceListParams) {
  return useQuery({
    queryKey: [ATTENDANCE_QUERY_KEY, "list", params],
    queryFn: () =>
      apiGet<Paginated<AttendanceRecord>>(
        "/attendance",
        params as Record<string, unknown>,
      ),
  });
}
