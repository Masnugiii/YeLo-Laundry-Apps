import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';

const attendanceSummary = AttendanceSummary(
  presentToday: 9,
  lateToday: 2,
  leaveToday: 1,
  notCheckedIn: 3,
);

final epposSyncStatus = EpposSyncStatus(
  isConnected: true,
  deviceName: 'EPPOS Fingerprint X1',
  lastSyncedAt: DateTime(2026, 8, 7, 9, 15),
  pendingRecords: 0,
);

final List<EmployeeAttendanceRecord> dummyAttendanceRecords = [
  const EmployeeAttendanceRecord(
    id: 'att-001',
    employeeName: 'Rina Wulandari',
    role: 'Kasir',
    status: AttendanceStatus.hadir,
    clockIn: '07.58',
    clockOut: null,
    fingerprintDeviceId: 'EPPOS-01',
  ),
  const EmployeeAttendanceRecord(
    id: 'att-002',
    employeeName: 'Budi Santoso',
    role: 'Binatu',
    status: AttendanceStatus.terlambat,
    clockIn: '08.17',
    clockOut: null,
    fingerprintDeviceId: 'EPPOS-01',
  ),
  const EmployeeAttendanceRecord(
    id: 'att-003',
    employeeName: 'Siti Rahayu',
    role: 'Kasir',
    status: AttendanceStatus.hadir,
    clockIn: '07.55',
    clockOut: null,
    fingerprintDeviceId: 'EPPOS-01',
  ),
  const EmployeeAttendanceRecord(
    id: 'att-004',
    employeeName: 'Andi Pratama',
    role: 'Binatu',
    status: AttendanceStatus.izin,
    clockIn: null,
    clockOut: null,
  ),
  const EmployeeAttendanceRecord(
    id: 'att-005',
    employeeName: 'Dewi Lestari',
    role: 'Manager',
    status: AttendanceStatus.hadir,
    clockIn: '07.50',
    clockOut: null,
    fingerprintDeviceId: 'EPPOS-01',
  ),
  const EmployeeAttendanceRecord(
    id: 'att-006',
    employeeName: 'Rizky Pratama',
    role: 'Binatu',
    status: AttendanceStatus.belumAbsen,
    clockIn: null,
    clockOut: null,
  ),
  const EmployeeAttendanceRecord(
    id: 'att-007',
    employeeName: 'Maya Anggraini',
    role: 'Kasir',
    status: AttendanceStatus.hadir,
    clockIn: '08.00',
    clockOut: null,
    fingerprintDeviceId: 'EPPOS-01',
  ),
  const EmployeeAttendanceRecord(
    id: 'att-008',
    employeeName: 'Fitri Handayani',
    role: 'Binatu',
    status: AttendanceStatus.terlambat,
    clockIn: '08.22',
    clockOut: null,
    fingerprintDeviceId: 'EPPOS-01',
  ),
];
