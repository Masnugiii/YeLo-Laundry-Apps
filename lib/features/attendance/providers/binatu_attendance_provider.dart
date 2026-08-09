import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/features/attendance/data/dummy_binatu_attendance_data.dart';
import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';
import 'package:yelo_laundry_erp/features/attendance/models/personal_attendance_models.dart';

class BinatuAttendanceNotifier extends Notifier<PersonalAttendanceState> {
  DateTime? _checkInDateTime;

  @override
  PersonalAttendanceState build() => initialBinatuAttendanceState();

  void checkIn() {
    if (!state.canCheckIn) return;

    final now = DateTime.now();
    _checkInDateTime = now;
    final isLate = now.hour > 8 || (now.hour == 8 && now.minute > 0);

    state = state.copyWith(
      today: PersonalAttendanceDay(
        date: state.today.date,
        status: isLate ? AttendanceStatus.terlambat : AttendanceStatus.hadir,
        checkIn: formatAttendanceClockTime(now),
      ),
      epposDeviceId: state.epposDeviceId ?? 'EPPOS-01',
    );
  }

  void checkOut() {
    if (!state.canCheckOut || _checkInDateTime == null) return;

    final now = DateTime.now();
    final workingHours = formatWorkingHours(now.difference(_checkInDateTime!));

    state = state.copyWith(
      today: PersonalAttendanceDay(
        date: state.today.date,
        status: state.today.status,
        checkIn: state.today.checkIn,
        checkOut: formatAttendanceClockTime(now),
        workingHours: workingHours,
      ),
    );
  }
}

final binatuAttendanceProvider =
    NotifierProvider<BinatuAttendanceNotifier, PersonalAttendanceState>(
  BinatuAttendanceNotifier.new,
);
