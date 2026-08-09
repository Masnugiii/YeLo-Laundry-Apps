import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/attendance_theme.dart';

class AttendanceSummaryGrid extends StatelessWidget {
  const AttendanceSummaryGrid({
    super.key,
    required this.summary,
  });

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Hadir Hari Ini',
                value: '${summary.presentToday}',
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _SummaryCard(
                label: 'Terlambat',
                value: '${summary.lateToday}',
                color: const Color(0xFFF57F17),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Izin / Sakit',
                value: '${summary.leaveToday}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _SummaryCard(
                label: 'Belum Absen',
                value: '${summary.notCheckedIn}',
                color: const Color(0xFF546E7A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: AttendanceTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AttendanceTheme.labelStyle),
          const SizedBox(height: AppSpacing.s8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
