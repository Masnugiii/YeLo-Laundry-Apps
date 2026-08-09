import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';

class UpcomingMaintenanceCard extends StatelessWidget {
  const UpcomingMaintenanceCard({
    super.key,
    required this.schedule,
  });

  final UpcomingMaintenanceSchedule schedule;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s8,
        AppSpacing.s20,
        AppSpacing.s16,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.s8),
                Text(
                  'Jadwal Berikutnya',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            _ScheduleRow(
              label: 'Service Mesin',
              date: schedule.machineServiceDate,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
              child: Divider(height: 1, color: AppColors.divider),
            ),
            _ScheduleRow(
              label: 'Routine Cleaning',
              date: schedule.routineCleaningDate,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.label,
    required this.date,
  });

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: SettingsTheme.tileTitleStyle),
        ),
        Text(
          date,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
