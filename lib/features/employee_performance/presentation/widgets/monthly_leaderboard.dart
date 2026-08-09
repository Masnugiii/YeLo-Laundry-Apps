import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/models/employee_performance_models.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/performance_theme.dart';

class MonthlyLeaderboard extends StatelessWidget {
  const MonthlyLeaderboard({
    super.key,
    required this.entries,
  });

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    return PerformanceTheme.sectionCard(
      title: 'Monthly Leaderboard',
      subtitle: 'Peringkat kinerja bulan ini.',
      child: Column(
        children: [
          _HeaderRow(),
          const SizedBox(height: AppSpacing.s12),
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s8),
            _LeaderboardRow(
              entry: entries[i],
              onTap: () => context.push(
                '/employee-performance/${entries[i].employeeId}',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            'Rank',
            style: _headerStyle,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text('Employee', style: _headerStyle),
        ),
        Expanded(
          flex: 2,
          child: Text('Role', style: _headerStyle),
        ),
        SizedBox(
          width: 48,
          child: Text(
            'Point',
            style: _headerStyle,
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          flex: 3,
          child: Text(
            'Est. Bonus',
            style: _headerStyle,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  TextStyle get _headerStyle => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.onTap,
  });

  final LeaderboardEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isTop = entry.rank <= 3;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s8,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isTop
                ? AppColors.accent.withValues(alpha: 0.1)
                : AppColors.dashboardBackground,
            borderRadius: BorderRadius.circular(12),
            border: isTop
                ? Border.all(color: AppColors.accent, width: 1)
                : Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '#${entry.rank}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isTop ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  entry.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  entry.role.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '${entry.points}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                flex: 3,
                child: Text(
                  entry.estimatedBonus,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
