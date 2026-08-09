import 'package:flutter/material.dart';

enum AttendanceStatus {
  hadir,
  terlambat,
  izin,
  sakit,
  belumAbsen,
}

extension AttendanceStatusX on AttendanceStatus {
  String get label => switch (this) {
        AttendanceStatus.hadir => 'Hadir',
        AttendanceStatus.terlambat => 'Terlambat',
        AttendanceStatus.izin => 'Izin',
        AttendanceStatus.sakit => 'Sakit',
        AttendanceStatus.belumAbsen => 'Belum Absen',
      };

  Color get backgroundColor => switch (this) {
        AttendanceStatus.hadir => const Color(0xFFE8F5E9),
        AttendanceStatus.terlambat => const Color(0xFFFFF8E1),
        AttendanceStatus.izin => const Color(0xFFE3F2FD),
        AttendanceStatus.sakit => const Color(0xFFFFEBEE),
        AttendanceStatus.belumAbsen => const Color(0xFFECEFF1),
      };

  Color get textColor => switch (this) {
        AttendanceStatus.hadir => const Color(0xFF2E7D32),
        AttendanceStatus.terlambat => const Color(0xFFF57F17),
        AttendanceStatus.izin => const Color(0xFF033B8E),
        AttendanceStatus.sakit => const Color(0xFFC62828),
        AttendanceStatus.belumAbsen => const Color(0xFF546E7A),
      };
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.presentToday,
    required this.lateToday,
    required this.leaveToday,
    required this.notCheckedIn,
  });

  final int presentToday;
  final int lateToday;
  final int leaveToday;
  final int notCheckedIn;
}

class EmployeeAttendanceRecord {
  const EmployeeAttendanceRecord({
    required this.id,
    required this.employeeName,
    required this.role,
    required this.status,
    this.clockIn,
    this.clockOut,
    this.fingerprintDeviceId,
  });

  final String id;
  final String employeeName;
  final String role;
  final AttendanceStatus status;
  final String? clockIn;
  final String? clockOut;
  final String? fingerprintDeviceId;
}

class EpposSyncStatus {
  const EpposSyncStatus({
    required this.isConnected,
    required this.deviceName,
    required this.lastSyncedAt,
    required this.pendingRecords,
  });

  final bool isConnected;
  final String deviceName;
  final DateTime lastSyncedAt;
  final int pendingRecords;
}

String formatAttendanceSyncTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour.$minute WIB';
}
