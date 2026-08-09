import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';
import 'package:yelo_laundry_erp/features/attendance/models/binatu_attendance_permissions.dart';

class PersonalAttendanceProfile {
  const PersonalAttendanceProfile({
    required this.employeeId,
    required this.name,
    required this.position,
    this.photoUrl,
  });

  final String employeeId;
  final String name;
  final String position;
  final String? photoUrl;
}

class PersonalAttendanceDay {
  const PersonalAttendanceDay({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.workingHours,
  });

  final DateTime date;
  final AttendanceStatus status;
  final String? checkIn;
  final String? checkOut;
  final String? workingHours;

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    return '$day $month ${date.year}';
  }
}

class PersonalAttendanceState {
  const PersonalAttendanceState({
    required this.profile,
    required this.today,
    required this.history,
    this.epposDeviceId,
  });

  final PersonalAttendanceProfile profile;
  final PersonalAttendanceDay today;
  final List<PersonalAttendanceDay> history;
  final String? epposDeviceId;

  bool get canCheckIn =>
      BinatuAttendancePermissions.checkIn &&
      today.checkIn == null &&
      today.status != AttendanceStatus.izin &&
      today.status != AttendanceStatus.sakit;

  bool get canCheckOut =>
      BinatuAttendancePermissions.checkOut &&
      today.checkIn != null &&
      today.checkOut == null;

  PersonalAttendanceState copyWith({
    PersonalAttendanceDay? today,
    List<PersonalAttendanceDay>? history,
    String? epposDeviceId,
  }) {
    return PersonalAttendanceState(
      profile: profile,
      today: today ?? this.today,
      history: history ?? this.history,
      epposDeviceId: epposDeviceId ?? this.epposDeviceId,
    );
  }
}

String formatAttendanceClockTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute WIB';
}

String formatWorkingHours(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return '$hours Jam ${minutes.toString().padLeft(2, '0')} Menit';
}
