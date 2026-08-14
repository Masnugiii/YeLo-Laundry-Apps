/// Helper for formatting the current date in Indonesian for dashboard display.
abstract final class DateDisplayHelper {
  static const _weekdays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String longIndonesianDate(DateTime dateTime) {
    final weekday = _weekdays[dateTime.weekday - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _months[dateTime.month - 1];

    return '$weekday, $day $month ${dateTime.year}';
  }

  static String shortIndonesianDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _months[dateTime.month - 1];

    return '$day $month ${dateTime.year}';
  }

  static String currentLongIndonesianDate() => longIndonesianDate(DateTime.now());

  /// ISO date (`yyyy-MM-dd`) for order list API filters.
  static String todayApiDateParam([DateTime? dateTime]) {
    final now = dateTime ?? DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
