import 'package:yelo_laundry_erp/features/employee_performance/models/employee_performance_models.dart';

const performanceSummary = PerformanceSummary(
  totalEmployees: 12,
  excellent: 3,
  good: 5,
  needImprovement: 4,
);

const _employees = <EmployeeOverview>[
  EmployeeOverview(
    id: 'emp-001',
    name: 'Budi Santoso',
    role: EmployeeRole.binatu,
    currentPoints: 420,
    performanceScore: 94,
    level: PerformanceLevel.excellent,
    ranking: 1,
  ),
  EmployeeOverview(
    id: 'emp-002',
    name: 'Siti Rahayu',
    role: EmployeeRole.kasir,
    currentPoints: 385,
    performanceScore: 91,
    level: PerformanceLevel.excellent,
    ranking: 2,
  ),
  EmployeeOverview(
    id: 'emp-003',
    name: 'Andi Pratama',
    role: EmployeeRole.binatu,
    currentPoints: 360,
    performanceScore: 88,
    level: PerformanceLevel.excellent,
    ranking: 3,
  ),
  EmployeeOverview(
    id: 'emp-004',
    name: 'Dewi Lestari',
    role: EmployeeRole.kasir,
    currentPoints: 310,
    performanceScore: 82,
    level: PerformanceLevel.good,
    ranking: 4,
  ),
  EmployeeOverview(
    id: 'emp-005',
    name: 'Rizky Hidayat',
    role: EmployeeRole.binatu,
    currentPoints: 295,
    performanceScore: 79,
    level: PerformanceLevel.good,
    ranking: 5,
  ),
  EmployeeOverview(
    id: 'emp-006',
    name: 'Maya Sari',
    role: EmployeeRole.kasir,
    currentPoints: 280,
    performanceScore: 76,
    level: PerformanceLevel.good,
    ranking: 6,
  ),
  EmployeeOverview(
    id: 'emp-007',
    name: 'Joko Widodo',
    role: EmployeeRole.binatu,
    currentPoints: 265,
    performanceScore: 74,
    level: PerformanceLevel.good,
    ranking: 7,
  ),
  EmployeeOverview(
    id: 'emp-008',
    name: 'Rina Wulandari',
    role: EmployeeRole.kasir,
    currentPoints: 250,
    performanceScore: 72,
    level: PerformanceLevel.good,
    ranking: 8,
  ),
  EmployeeOverview(
    id: 'emp-009',
    name: 'Agus Setiawan',
    role: EmployeeRole.binatu,
    currentPoints: 210,
    performanceScore: 65,
    level: PerformanceLevel.needImprovement,
    ranking: 9,
  ),
  EmployeeOverview(
    id: 'emp-010',
    name: 'Fitri Handayani',
    role: EmployeeRole.kasir,
    currentPoints: 195,
    performanceScore: 62,
    level: PerformanceLevel.needImprovement,
    ranking: 10,
  ),
  EmployeeOverview(
    id: 'emp-011',
    name: 'Hendra Gunawan',
    role: EmployeeRole.binatu,
    currentPoints: 180,
    performanceScore: 58,
    level: PerformanceLevel.needImprovement,
    ranking: 11,
  ),
  EmployeeOverview(
    id: 'emp-012',
    name: 'Lina Marlina',
    role: EmployeeRole.kasir,
    currentPoints: 165,
    performanceScore: 55,
    level: PerformanceLevel.needImprovement,
    ranking: 12,
  ),
];

List<EmployeeOverview> get dummyEmployeeOverviews => List.unmodifiable(_employees);

EmployeeOverview? findEmployeeOverview(String id) {
  for (final employee in _employees) {
    if (employee.id == id) return employee;
  }
  return null;
}

const binatuAutoMetrics = [
  'Total Kg Laundry Diselesaikan',
  'Target Kg Harian',
  'Jumlah Order Diselesaikan',
  'Ketepatan Deadline',
  'Jumlah Komplain Customer',
  'Produktivitas Bulanan',
];

const kasirAutoMetrics = [
  'Order Baru',
  'Customer Baru',
  'Top Up Wallet',
  'Pembayaran Berhasil',
  'Komplain Customer',
  'Total Transaksi',
];

const binatuDailyExample = BinatuDailyMetrics(
  kgToday: 128,
  dailyTargetKg: 100,
  status: PerformanceLevel.excellent,
  pointsEarned: 20,
);

const kasirDailyExample = KasirDailyMetrics(
  orders: 38,
  walletTopUps: 12,
  newCustomers: 7,
  points: 145,
);

const pointRules = <PointRule>[
  PointRule(category: 'Laundry', condition: '>=100 Kg', points: 20),
  PointRule(category: 'Laundry', condition: '80-99 Kg', points: 10),
  PointRule(category: 'Customer Complaint', condition: 'Per komplain', points: -15),
  PointRule(category: 'New Customer', condition: 'Per customer baru', points: 10),
  PointRule(category: 'Wallet Top Up', condition: 'Per transaksi', points: 5),
];

const aiPerformanceInsights = <AiPerformanceInsight>[
  AiPerformanceInsight(
    insight: 'Budi berhasil menyelesaikan target selama 15 hari berturut-turut.',
    recommendation: 'Layak mendapatkan bonus bulanan.',
  ),
  AiPerformanceInsight(
    insight: 'Andi mengalami peningkatan produktivitas 18%.',
    recommendation: 'Pertahankan target saat ini.',
  ),
  AiPerformanceInsight(
    insight: 'Siti menerima 3 komplain bulan ini.',
    recommendation: 'Lakukan evaluasi SOP penyetrikaan.',
  ),
];

const monthlyLeaderboard = <LeaderboardEntry>[
  LeaderboardEntry(
    rank: 1,
    employeeId: 'emp-001',
    name: 'Budi Santoso',
    role: EmployeeRole.binatu,
    points: 420,
    estimatedBonus: 'Rp750.000',
  ),
  LeaderboardEntry(
    rank: 2,
    employeeId: 'emp-002',
    name: 'Siti Rahayu',
    role: EmployeeRole.kasir,
    points: 385,
    estimatedBonus: 'Rp650.000',
  ),
  LeaderboardEntry(
    rank: 3,
    employeeId: 'emp-003',
    name: 'Andi Pratama',
    role: EmployeeRole.binatu,
    points: 360,
    estimatedBonus: 'Rp600.000',
  ),
  LeaderboardEntry(
    rank: 4,
    employeeId: 'emp-004',
    name: 'Dewi Lestari',
    role: EmployeeRole.kasir,
    points: 310,
    estimatedBonus: 'Rp450.000',
  ),
  LeaderboardEntry(
    rank: 5,
    employeeId: 'emp-005',
    name: 'Rizky Hidayat',
    role: EmployeeRole.binatu,
    points: 295,
    estimatedBonus: 'Rp400.000',
  ),
];

EmployeeDetail? findEmployeeDetail(String id) {
  final overview = findEmployeeOverview(id);
  if (overview == null) return null;

  return EmployeeDetail(
    overview: overview,
    monthlyRanking: overview.ranking,
    timeline: _timelineForEmployee(overview),
  );
}

List<ActivityTimelineEvent> _timelineForEmployee(EmployeeOverview employee) {
  if (employee.role == EmployeeRole.binatu) {
    return [
      ActivityTimelineEvent(
        date: DateTime(2026, 8, 8, 14, 30),
        title: 'Laundry selesai',
        detail: '+12 Kg',
        points: 12,
      ),
      ActivityTimelineEvent(
        date: DateTime(2026, 8, 8, 10, 15),
        title: 'Laundry selesai',
        detail: '+18 Kg',
        points: 18,
      ),
      ActivityTimelineEvent(
        date: DateTime(2026, 8, 7, 16, 45),
        title: 'Target harian tercapai',
        detail: '100 Kg',
        points: 20,
      ),
      ActivityTimelineEvent(
        date: DateTime(2026, 8, 6, 11, 20),
        title: 'Customer Complaint',
        points: -15,
      ),
    ];
  }

  return [
    ActivityTimelineEvent(
      date: DateTime(2026, 8, 8, 15, 10),
      title: 'Top Up Wallet',
      detail: 'Rp150.000',
      points: 5,
    ),
    ActivityTimelineEvent(
      date: DateTime(2026, 8, 8, 13, 40),
      title: 'Customer Baru',
      detail: 'John Anderson',
      points: 10,
    ),
    ActivityTimelineEvent(
      date: DateTime(2026, 8, 8, 9, 25),
      title: 'Pembayaran Berhasil',
      detail: 'Order #1024',
      points: 3,
    ),
    ActivityTimelineEvent(
      date: DateTime(2026, 8, 7, 17, 5),
      title: 'Order Baru',
      detail: 'Order #1020',
      points: 2,
    ),
  ];
}
