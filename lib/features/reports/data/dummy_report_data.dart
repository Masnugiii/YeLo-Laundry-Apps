import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

const dummyFinancialOverview = FinancialOverview(
  grossRevenue: 15250000,
  netRevenue: 11850000,
  totalExpenses: 3400000,
  netProfit: 8450000,
);

const dummyRevenueTrend = <RevenueTrendPoint>[
  RevenueTrendPoint(month: 'Jan', grossRevenue: 9.2, netRevenue: 7.1),
  RevenueTrendPoint(month: 'Feb', grossRevenue: 10.5, netRevenue: 8.0),
  RevenueTrendPoint(month: 'Mar', grossRevenue: 11.8, netRevenue: 9.2),
  RevenueTrendPoint(month: 'Apr', grossRevenue: 12.4, netRevenue: 9.6),
  RevenueTrendPoint(month: 'Mei', grossRevenue: 13.1, netRevenue: 10.2),
  RevenueTrendPoint(month: 'Jun', grossRevenue: 14.0, netRevenue: 10.8),
  RevenueTrendPoint(month: 'Jul', grossRevenue: 14.8, netRevenue: 11.3),
  RevenueTrendPoint(month: 'Agu', grossRevenue: 15.2, netRevenue: 11.8),
];

const dummyBinatuPerformance = BinatuPerformance(
  completedKg: 520,
  monthlyTargetKg: 650,
  progressPercent: 80,
);

const dummyEmployeePerformance = <EmployeePerformance>[
  EmployeePerformance(name: 'Budi', completedKg: 145, rank: 1),
  EmployeePerformance(name: 'Andi', completedKg: 128, rank: 2),
  EmployeePerformance(name: 'Siti', completedKg: 95, rank: 3),
  EmployeePerformance(name: 'Rina', completedKg: 82, rank: 4),
];

const dummyCustomerReviews = <CustomerReview>[
  CustomerReview(
    customerName: 'Siti Rahayu',
    rating: 5,
    comment: 'Pakaian bersih dan wangi.',
    date: '07 Agustus 2026',
  ),
  CustomerReview(
    customerName: 'Budi Santoso',
    rating: 4,
    comment: 'Kurir datang tepat waktu.',
    date: '06 Agustus 2026',
  ),
  CustomerReview(
    customerName: 'Dewi Lestari',
    rating: 5,
    comment: 'Pelayanan cepat.',
    date: '05 Agustus 2026',
  ),
];

final dummyBusyDaysAugust2026 = <BusyDayEntry>[
  const BusyDayEntry(day: 1, level: BusyDayLevel.quiet),
  const BusyDayEntry(day: 2, level: BusyDayLevel.normal),
  const BusyDayEntry(day: 3, level: BusyDayLevel.busy),
  const BusyDayEntry(day: 4, level: BusyDayLevel.veryBusy),
  const BusyDayEntry(day: 5, level: BusyDayLevel.busy),
  const BusyDayEntry(day: 6, level: BusyDayLevel.normal),
  const BusyDayEntry(day: 7, level: BusyDayLevel.veryBusy),
  const BusyDayEntry(day: 8, level: BusyDayLevel.quiet),
  const BusyDayEntry(day: 9, level: BusyDayLevel.normal),
  const BusyDayEntry(day: 10, level: BusyDayLevel.busy),
  const BusyDayEntry(day: 11, level: BusyDayLevel.veryBusy),
  const BusyDayEntry(day: 12, level: BusyDayLevel.busy),
  const BusyDayEntry(day: 13, level: BusyDayLevel.normal),
  const BusyDayEntry(day: 14, level: BusyDayLevel.quiet),
  const BusyDayEntry(day: 15, level: BusyDayLevel.busy),
  const BusyDayEntry(day: 16, level: BusyDayLevel.normal),
  const BusyDayEntry(day: 17, level: BusyDayLevel.veryBusy),
  const BusyDayEntry(day: 18, level: BusyDayLevel.busy),
  const BusyDayEntry(day: 19, level: BusyDayLevel.normal),
  const BusyDayEntry(day: 20, level: BusyDayLevel.quiet),
  const BusyDayEntry(day: 21, level: BusyDayLevel.busy),
  const BusyDayEntry(day: 22, level: BusyDayLevel.veryBusy),
  const BusyDayEntry(day: 23, level: BusyDayLevel.normal),
  const BusyDayEntry(day: 24, level: BusyDayLevel.busy),
  const BusyDayEntry(day: 25, level: BusyDayLevel.quiet),
  const BusyDayEntry(day: 26, level: BusyDayLevel.normal),
  const BusyDayEntry(day: 27, level: BusyDayLevel.busy),
  const BusyDayEntry(day: 28, level: BusyDayLevel.veryBusy),
  const BusyDayEntry(day: 29, level: BusyDayLevel.normal),
  const BusyDayEntry(day: 30, level: BusyDayLevel.busy),
  const BusyDayEntry(day: 31, level: BusyDayLevel.quiet),
];

const dummyAiRecommendations = <AiRecommendation>[
  AiRecommendation(
    insight: 'Hari Selasa cenderung sepi.',
    recommendation: 'Promo Cuci Kering Lipat 10%.',
  ),
  AiRecommendation(
    insight: 'Hari Kamis memiliki banyak pelanggan tetap.',
    recommendation: 'Tambahkan promo Point Reward.',
  ),
  AiRecommendation(
    insight: 'Banyak pelanggan menggunakan layanan Regular.',
    recommendation: 'Promosikan layanan Express.',
  ),
  AiRecommendation(
    insight: 'Omzet turun 12% dibanding minggu lalu.',
    recommendation:
        'Broadcast promo WhatsApp kepada pelanggan yang belum order selama 30 hari.',
  ),
];

const dummyTopServices = <TopService>[
  TopService(name: 'Cuci Kering Lipat', orderCount: 320),
  TopService(name: 'Cuci Kering Setrika', orderCount: 280),
  TopService(name: 'Express', orderCount: 90),
  TopService(name: 'Bed Cover', orderCount: 35),
];

const dummyTopCustomers = <TopCustomer>[
  TopCustomer(
    name: 'Maya Anggraini',
    totalSpending: 2850000,
    totalOrders: 42,
    points: 1200,
  ),
  TopCustomer(
    name: 'Andi Saputra',
    totalSpending: 1950000,
    totalOrders: 28,
    points: 350,
  ),
  TopCustomer(
    name: 'Siti Rahayu',
    totalSpending: 1720000,
    totalOrders: 24,
    points: 520,
  ),
];

const dummyPaymentAnalytics = <PaymentAnalytic>[
  PaymentAnalytic(
    method: 'Cash',
    percentage: 38,
    color: AppColors.primary,
  ),
  PaymentAnalytic(
    method: 'QRIS',
    percentage: 32,
    color: AppColors.accent,
  ),
  PaymentAnalytic(
    method: 'Transfer',
    percentage: 18,
    color: Color(0xFF60A5FA),
  ),
  PaymentAnalytic(
    method: 'Wallet',
    percentage: 12,
    color: Color(0xFF22C55E),
  ),
];
