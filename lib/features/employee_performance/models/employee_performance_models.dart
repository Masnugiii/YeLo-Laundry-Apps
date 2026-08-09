enum EmployeeRole {
  binatu,
  kasir,
}

extension EmployeeRoleX on EmployeeRole {
  String get label => switch (this) {
        EmployeeRole.binatu => 'Binatu',
        EmployeeRole.kasir => 'Kasir',
      };
}

enum PerformanceLevel {
  excellent,
  good,
  needImprovement,
}

extension PerformanceLevelX on PerformanceLevel {
  String get label => switch (this) {
        PerformanceLevel.excellent => 'Excellent',
        PerformanceLevel.good => 'Good',
        PerformanceLevel.needImprovement => 'Need Improvement',
      };
}

class PerformanceSummary {
  const PerformanceSummary({
    required this.totalEmployees,
    required this.excellent,
    required this.good,
    required this.needImprovement,
  });

  final int totalEmployees;
  final int excellent;
  final int good;
  final int needImprovement;
}

class EmployeeOverview {
  const EmployeeOverview({
    required this.id,
    required this.name,
    required this.role,
    required this.currentPoints,
    required this.performanceScore,
    required this.level,
    required this.ranking,
  });

  final String id;
  final String name;
  final EmployeeRole role;
  final int currentPoints;
  final int performanceScore;
  final PerformanceLevel level;
  final int ranking;
}

class BinatuDailyMetrics {
  const BinatuDailyMetrics({
    required this.kgToday,
    required this.dailyTargetKg,
    required this.status,
    required this.pointsEarned,
  });

  final int kgToday;
  final int dailyTargetKg;
  final PerformanceLevel status;
  final int pointsEarned;
}

class KasirDailyMetrics {
  const KasirDailyMetrics({
    required this.orders,
    required this.walletTopUps,
    required this.newCustomers,
    required this.points,
  });

  final int orders;
  final int walletTopUps;
  final int newCustomers;
  final int points;
}

class ActivityTimelineEvent {
  const ActivityTimelineEvent({
    required this.date,
    required this.title,
    this.detail,
    required this.points,
  });

  final DateTime date;
  final String title;
  final String? detail;
  final int points;
}

class PointRule {
  const PointRule({
    required this.category,
    required this.condition,
    required this.points,
  });

  final String category;
  final String condition;
  final int points;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.employeeId,
    required this.name,
    required this.role,
    required this.points,
    required this.estimatedBonus,
  });

  final int rank;
  final String employeeId;
  final String name;
  final EmployeeRole role;
  final int points;
  final String estimatedBonus;
}

class AiPerformanceInsight {
  const AiPerformanceInsight({
    required this.insight,
    required this.recommendation,
  });

  final String insight;
  final String recommendation;
}

class EmployeeDetail {
  const EmployeeDetail({
    required this.overview,
    required this.monthlyRanking,
    required this.timeline,
  });

  final EmployeeOverview overview;
  final int monthlyRanking;
  final List<ActivityTimelineEvent> timeline;

  EmployeeRole get role => overview.role;
  String get name => overview.name;
}
