import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';

class BinatuMonitoringEmptyState extends StatelessWidget {
  const BinatuMonitoringEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🧺',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Belum ada aktivitas Binatu pada tanggal ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
