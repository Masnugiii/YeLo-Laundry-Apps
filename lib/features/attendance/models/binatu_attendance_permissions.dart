/// Dummy permission map for Binatu attendance UI.
///
/// Will be replaced by backend authorization in a future sprint.
abstract final class BinatuAttendancePermissions {
  static const checkIn = true;
  static const checkOut = true;
  static const viewOwnAttendance = true;

  static const viewOtherAttendance = false;
  static const editAttendance = false;
  static const deleteAttendance = false;
  static const exportAttendance = false;
  static const searchEmployees = false;
  static const teamAttendance = false;
}
