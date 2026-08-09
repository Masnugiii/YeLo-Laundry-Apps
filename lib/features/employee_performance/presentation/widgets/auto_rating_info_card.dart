import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/performance_theme.dart';

class AutoRatingInfoCard extends StatelessWidget {
  const AutoRatingInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: PerformanceTheme.successBackground,
        borderRadius: PerformanceTheme.cardRadius,
        border: Border.all(color: PerformanceTheme.successBorder, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_mode,
            color: PerformanceTheme.successBorder,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistem Penilaian Otomatis',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PerformanceTheme.successBorder,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Seluruh nilai kinerja dihitung otomatis berdasarkan aktivitas karyawan di dalam sistem.\n\nOwner tidak perlu melakukan penilaian manual.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2E7D32),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
