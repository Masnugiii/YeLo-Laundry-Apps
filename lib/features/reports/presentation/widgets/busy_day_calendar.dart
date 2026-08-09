import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

class BusyDayCalendar extends StatelessWidget {
  const BusyDayCalendar({
    super.key,
    required this.entries,
    this.monthLabel = 'Agustus 2026',
  });

  final List<BusyDayEntry> entries;
  final String monthLabel;

  static const _weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final firstWeekdayOffset = 5; // Aug 1 2026 is Saturday -> offset 5 for Mon-start

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          monthLabel,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          children: [
            for (final day in _weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: firstWeekdayOffset + entries.length,
          itemBuilder: (context, index) {
            if (index < firstWeekdayOffset) {
              return const SizedBox.shrink();
            }

            final entry = entries[index - firstWeekdayOffset];
            final textColor = entry.level == BusyDayLevel.normal
                ? AppColors.primary
                : entry.level == BusyDayLevel.quiet
                    ? AppColors.textSecondary
                    : AppColors.onPrimary;

            return Container(
              decoration: BoxDecoration(
                color: entry.level.color,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${entry.day}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.s16),
        Wrap(
          spacing: AppSpacing.s12,
          runSpacing: AppSpacing.s8,
          children: BusyDayLevel.values.map((level) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: level.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: AppSpacing.s4),
                Text(
                  level.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
