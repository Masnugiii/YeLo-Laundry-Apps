export interface AttendanceDashboard {
  presentToday: number;
  lateToday: number;
  absentToday: number;
  onLeave: number;
  averageWorkingHours: number;
  totalOvertimeMinutes: number;
  attendancePercentage: number;
}

export interface AttendanceRecord {
  id: string;
  employeeId: string;
  employee: {
    id: string;
    fullName: string;
    employeeCode: string;
    phone: string;
  };
  attendanceDate: string;
  checkIn: string | null;
  checkOut: string | null;
  workingHours: number;
  breakDurationMinutes: number;
  overtimeMinutes: number;
  earlyLeaveMinutes: number;
  lateMinutes: number;
  status: string;
  displayStatus: string;
  shiftId: string | null;
  notes: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface AttendanceListParams {
  page?: number;
  limit?: number;
  search?: string;
  employeeId?: string;
  status?: string;
  shiftId?: string;
  date?: string;
  dateFrom?: string;
  dateTo?: string;
}
