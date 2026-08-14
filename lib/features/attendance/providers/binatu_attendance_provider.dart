import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/attendance/data/attendance_mapper.dart';
import 'package:yelo_laundry_erp/features/attendance/models/personal_attendance_models.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_employee_provider.dart';

const _locationPayload = {
  'latitude': -6.2088,
  'longitude': 106.8456,
  'accuracy': 10.0,
};

class BinatuAttendanceNotifier extends AsyncNotifier<PersonalAttendanceState> {
  @override
  Future<PersonalAttendanceState> build() => _load();

  Future<PersonalAttendanceState> _load() async {
    final employee = ref.read(dashboardEmployeeProvider);
    final records =
        await ref.read(attendanceRepositoryProvider).fetchHistory(limit: 30);

    return mapPersonalAttendanceState(
      employeeId: employee.name,
      employeeName: employee.name,
      position: employee.roleLabel,
      records: records,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> checkIn() async {
    await ref.read(attendanceRepositoryProvider).checkIn(_locationPayload);
    await refresh();
  }

  Future<void> checkOut() async {
    await ref.read(attendanceRepositoryProvider).checkOut(_locationPayload);
    await refresh();
  }
}

final binatuAttendanceProvider =
    AsyncNotifierProvider<BinatuAttendanceNotifier, PersonalAttendanceState>(
  BinatuAttendanceNotifier.new,
);
