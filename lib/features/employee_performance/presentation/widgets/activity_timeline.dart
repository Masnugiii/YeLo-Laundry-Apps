import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/models/employee_performance_models.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/performance_theme.dart';

const _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = _monthNames[date.month - 1];
  return '$day $month ${date.year}';
}

class ActivityTimeline extends StatelessWidget {
  const ActivityTimeline({
    super.key,
    required this.events,
  });

  final List<ActivityTimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    return PerformanceTheme.sectionCard(
      title: 'Activity Timeline',
      subtitle: 'Riwayat aktivitas KPI otomatis terbaru.',
      child: Column(
        children: [
          for (var i = 0; i < events.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s12),
            _TimelineItem(
              event: events[i],
              showDateHeader:
                  i == 0 || !_isSameDay(events[i].date, events[i - 1].date),
            ),
          ],
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.event,
    required this.showDateHeader,
  });

  final ActivityTimelineEvent event;
  final bool showDateHeader;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDate(event.date);
    final isNegative = event.points < 0;
    final pointColor = isNegative ? AppColors.error : AppColors.success;
    final pointText =
        isNegative ? '${event.points} Point' : '+${event.points} Point';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDateHeader) ...[
          Text(
            dateLabel,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: AppColors.dashboardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (event.detail != null) ...[
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        event.detail!,
                        style: PerformanceTheme.labelStyle,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                pointText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: pointColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
