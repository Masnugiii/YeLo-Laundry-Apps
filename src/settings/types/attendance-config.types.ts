export interface AttendanceGpsConfig {
  officeLatitude: number;
  officeLongitude: number;
  officeRadiusMeters: number;
}

export interface AttendanceConfig {
  id?: string;
  workStartTime: string;
  workEndTime: string;
  lateToleranceMinutes: number;
  overtimeEnabled: boolean;
  gps: AttendanceGpsConfig | null;
  shiftCount: number;
}

export interface UpdateAttendanceConfigInput {
  workStartTime?: string;
  workEndTime?: string;
  lateToleranceMinutes?: number;
  overtimeEnabled?: boolean;
  gps?: Partial<AttendanceGpsConfig> | null;
}
