import 'package:yelo_laundry_erp/core/utils/date_display_helper.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/models/binatu_monitoring_models.dart';

class BinatuMonitoringDateRange {
  const BinatuMonitoringDateRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return !normalized.isBefore(start) && !normalized.isAfter(end);
  }

  String get displayLabel {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return DateDisplayHelper.shortIndonesianDate(start);
    }

    return '${DateDisplayHelper.shortIndonesianDate(start)} – '
        '${DateDisplayHelper.shortIndonesianDate(end)}';
  }
}

abstract final class BinatuMonitoringDateHelper {
  static DateTime normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime today() => normalize(DateTime.now());

  static DateTime startOfWeek(DateTime date) {
    final normalized = normalize(date);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  static BinatuMonitoringDateRange resolveRange({
    required BinatuMonitoringDateFilter filter,
    required DateTime customDate,
  }) {
    final now = normalize(DateTime.now());
    final normalizedCustom = normalize(customDate);

    return switch (filter) {
      BinatuMonitoringDateFilter.today =>
        BinatuMonitoringDateRange(start: now, end: now),
      BinatuMonitoringDateFilter.yesterday => () {
          final yesterday = now.subtract(const Duration(days: 1));
          return BinatuMonitoringDateRange(start: yesterday, end: yesterday);
        }(),
      BinatuMonitoringDateFilter.thisWeek => BinatuMonitoringDateRange(
          start: startOfWeek(now),
          end: now,
        ),
      BinatuMonitoringDateFilter.thisMonth => BinatuMonitoringDateRange(
          start: startOfMonth(now),
          end: now,
        ),
      BinatuMonitoringDateFilter.custom => BinatuMonitoringDateRange(
          start: normalizedCustom,
          end: normalizedCustom,
        ),
    };
  }

  static DateTime displayDate({
    required BinatuMonitoringDateFilter filter,
    required DateTime customDate,
  }) {
    return resolveRange(filter: filter, customDate: customDate).end;
  }
}
