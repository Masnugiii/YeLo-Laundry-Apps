import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';
import 'package:yelo_laundry_erp/features/attendance/models/personal_attendance_models.dart';

PersonalAttendanceState initialBinatuAttendanceState() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return PersonalAttendanceState(
    profile: const PersonalAttendanceProfile(
      employeeId: 'emp-binatu-001',
      name: 'Pak Budi',
      position: 'Binatu',
    ),
    today: PersonalAttendanceDay(
      date: today,
      status: AttendanceStatus.belumAbsen,
    ),
    history: [
      PersonalAttendanceDay(
        date: today.subtract(const Duration(days: 1)),
        status: AttendanceStatus.hadir,
        checkIn: '08:01 WIB',
        checkOut: '17:05 WIB',
        workingHours: '9 Jam 04 Menit',
      ),
      PersonalAttendanceDay(
        date: today.subtract(const Duration(days: 2)),
        status: AttendanceStatus.terlambat,
        checkIn: '08:18 WIB',
        checkOut: '17:10 WIB',
        workingHours: '8 Jam 52 Menit',
      ),
      PersonalAttendanceDay(
        date: today.subtract(const Duration(days: 3)),
        status: AttendanceStatus.hadir,
        checkIn: '07:58 WIB',
        checkOut: '17:00 WIB',
        workingHours: '9 Jam 02 Menit',
      ),
      PersonalAttendanceDay(
        date: today.subtract(const Duration(days: 4)),
        status: AttendanceStatus.hadir,
        checkIn: '08:00 WIB',
        checkOut: '17:02 WIB',
        workingHours: '9 Jam 02 Menit',
      ),
      PersonalAttendanceDay(
        date: today.subtract(const Duration(days: 5)),
        status: AttendanceStatus.izin,
      ),
    ],
    epposDeviceId: 'EPPOS-01',
  );
}
