import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/performance_theme.dart';

class EmployeeApiKpiSection extends StatelessWidget {
  const EmployeeApiKpiSection({
    super.key,
    required this.metrics,
  });

  final Map<String, dynamic> metrics;

  String _formatCurrency(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Kehadiran (hari)', '${metrics['attendanceDays'] ?? 0}'),
      ('Order selesai', '${metrics['ordersCompleted'] ?? 0}'),
      ('Kg diproses', '${metrics['kgProcessed'] ?? 0}'),
      ('Bonus', _formatCurrency((metrics['bonusEarned'] as num?) ?? 0)),
      ('Payroll', _formatCurrency((metrics['payroll'] as num?) ?? 0)),
      ('Revenue handled', _formatCurrency((metrics['revenueHandled'] as num?) ?? 0)),
      ('Produktivitas', '${metrics['productivity'] ?? 0}%'),
    ];

    return PerformanceTheme.sectionCard(
      title: 'KPI Karyawan',
      subtitle: 'Data dari laporan backend bulan ini.',
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    rows[i].$1,
                    style: PerformanceTheme.labelStyle,
                  ),
                ),
                Text(
                  rows[i].$2,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
