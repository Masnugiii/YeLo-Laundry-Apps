import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';
import 'package:yelo_laundry_erp/features/attendance/models/personal_attendance_models.dart';

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

String formatWorkingHoursFromMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  return '$hours Jam ${remainingMinutes.toString().padLeft(2, '0')} Menit';
}

PersonalAttendanceDay mapPersonalAttendanceDay(Map<String, dynamic> json) {
  final attendanceDate = DateTime.tryParse(
        json['attendanceDate'] as String? ?? '',
      ) ??
      DateTime.now();

  final workingHoursMinutes =
      ((json['workingHours'] as num?)?.toDouble() ?? 0) * 60;

  return PersonalAttendanceDay(
    date: DateTime(
      attendanceDate.year,
      attendanceDate.month,
      attendanceDate.day,
    ),
    status: mapAttendanceStatus(json['status'] as String?),
    checkIn: _formatClockTime(json['checkIn'] as String?),
    checkOut: _formatClockTime(json['checkOut'] as String?),
    workingHours: workingHoursMinutes > 0
        ? formatWorkingHoursFromMinutes(workingHoursMinutes.round())
        : null,
  );
}

PersonalAttendanceState mapPersonalAttendanceState({
  required String employeeId,
  required String employeeName,
  required String position,
  required List<Map<String, dynamic>> records,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final history = records.map(mapPersonalAttendanceDay).toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  PersonalAttendanceDay? todayRecord;
  for (final record in history) {
    if (record.date.year == today.year &&
        record.date.month == today.month &&
        record.date.day == today.day) {
      todayRecord = record;
      break;
    }
  }

  return PersonalAttendanceState(
    profile: PersonalAttendanceProfile(
      employeeId: employeeId,
      name: employeeName,
      position: position,
    ),
    today: todayRecord ??
        PersonalAttendanceDay(
          date: today,
          status: AttendanceStatus.belumAbsen,
        ),
    history: history,
  );
}
