import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';

AttendanceStatus mapAttendanceStatus(String? status) {
  switch (status?.toUpperCase()) {
    case 'PRESENT':
      return AttendanceStatus.hadir;
    case 'LATE':
      return AttendanceStatus.terlambat;
    case 'LEAVE':
      return AttendanceStatus.izin;
    case 'SICK':
      return AttendanceStatus.sakit;
    default:
      return AttendanceStatus.belumAbsen;
  }
}

String? _formatClockTime(String? value) {
  final parsed = DateTime.tryParse(value ?? '');
  if (parsed == null) {
    return null;
  }

  final hour = parsed.hour.toString().padLeft(2, '0');
  final minute = parsed.minute.toString().padLeft(2, '0');
  return '$hour.$minute';
}

EmployeeAttendanceRecord mapEmployeeAttendanceRecord(
  Map<String, dynamic> json,
) {
  final employee = json['employee'] as Map<String, dynamic>? ?? {};

  return EmployeeAttendanceRecord(
    id: json['id'] as String? ?? '',
    employeeName: employee['fullName'] as String? ?? '-',
    role: employee['employeeCode'] as String? ?? '-',
    status: mapAttendanceStatus(json['status'] as String?),
    clockIn: _formatClockTime(json['checkIn'] as String?),
    clockOut: _formatClockTime(json['checkOut'] as String?),
    fingerprintDeviceId: json['deviceInfo'] as String?,
  );
}

AttendanceSummary mapAttendanceSummary(Map<String, dynamic> json) {
  return AttendanceSummary(
    presentToday: (json['presentToday'] as num?)?.toInt() ?? 0,
    lateToday: (json['lateToday'] as num?)?.toInt() ?? 0,
    leaveToday: (json['onLeave'] as num?)?.toInt() ?? 0,
    notCheckedIn: (json['absentToday'] as num?)?.toInt() ?? 0,
  );
}
