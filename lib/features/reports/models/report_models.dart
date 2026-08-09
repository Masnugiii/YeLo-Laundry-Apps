import 'package:flutter/material.dart';

enum ReportPeriodFilter {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  customRange,
}

extension ReportPeriodFilterX on ReportPeriodFilter {
  String get label => switch (this) {
        ReportPeriodFilter.today => 'Hari Ini',
        ReportPeriodFilter.thisWeek => 'Minggu Ini',
        ReportPeriodFilter.thisMonth => 'Bulan Ini',
        ReportPeriodFilter.thisYear => 'Tahun Ini',
        ReportPeriodFilter.customRange => 'Custom Range',
      };
}

class FinancialOverview {
  const FinancialOverview({
    required this.grossRevenue,
    required this.netRevenue,
    required this.totalExpenses,
    required this.netProfit,
  });

  final int grossRevenue;
  final int netRevenue;
  final int totalExpenses;
  final int netProfit;
}

class RevenueTrendPoint {
  const RevenueTrendPoint({
    required this.month,
    required this.grossRevenue,
    required this.netRevenue,
  });

  final String month;
  final double grossRevenue;
  final double netRevenue;
}

class BinatuPerformance {
  const BinatuPerformance({
    required this.completedKg,
    required this.monthlyTargetKg,
    required this.progressPercent,
  });

  final int completedKg;
  final int monthlyTargetKg;
  final int progressPercent;
}

class EmployeePerformance {
  const EmployeePerformance({
    required this.name,
    required this.completedKg,
    required this.rank,
  });

  final String name;
  final int completedKg;
  final int rank;
}

class CustomerReview {
  const CustomerReview({
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String customerName;
  final int rating;
  final String comment;
  final String date;
}

enum BusyDayLevel {
  veryBusy,
  busy,
  normal,
  quiet,
}

extension BusyDayLevelX on BusyDayLevel {
  Color get color => switch (this) {
        BusyDayLevel.veryBusy => const Color(0xFF022A63),
        BusyDayLevel.busy => const Color(0xFF033B8E),
        BusyDayLevel.normal => const Color(0xFFF8D613),
        BusyDayLevel.quiet => const Color(0xFFE5E7EB),
      };

  String get label => switch (this) {
        BusyDayLevel.veryBusy => 'Sangat Ramai',
        BusyDayLevel.busy => 'Ramai',
        BusyDayLevel.normal => 'Normal',
        BusyDayLevel.quiet => 'Sepi',
      };
}

class BusyDayEntry {
  const BusyDayEntry({
    required this.day,
    required this.level,
  });

  final int day;
  final BusyDayLevel level;
}

class AiRecommendation {
  const AiRecommendation({
    required this.insight,
    required this.recommendation,
  });

  final String insight;
  final String recommendation;
}

class TopService {
  const TopService({
    required this.name,
    required this.orderCount,
  });

  final String name;
  final int orderCount;
}

class TopCustomer {
  const TopCustomer({
    required this.name,
    required this.totalSpending,
    required this.totalOrders,
    required this.points,
  });

  final String name;
  final int totalSpending;
  final int totalOrders;
  final int points;
}

class PaymentAnalytic {
  const PaymentAnalytic({
    required this.method,
    required this.percentage,
    required this.color,
  });

  final String method;
  final double percentage;
  final Color color;
}
