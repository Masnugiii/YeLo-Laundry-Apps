import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class DashboardMenuEntry {
  const DashboardMenuEntry({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;
}

class DashboardMenuTile extends StatelessWidget {
  const DashboardMenuTile({
    super.key,
    required this.entry,
  });

  final DashboardMenuEntry entry;

  @override
  Widget build(BuildContext context) {
    final labelColor =
        entry.isDestructive ? Colors.red.shade700 : AppColors.textPrimary;
    final iconColor =
        entry.isDestructive ? Colors.red.shade700 : AppColors.brandBlue;
    final hasValue = entry.value != null && entry.value!.isNotEmpty;
    final showChevron = entry.onTap != null && entry.trailing == null;

    return InkWell(
      onTap: entry.trailing != null ? null : entry.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          crossAxisAlignment:
              hasValue ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: entry.isDestructive
                    ? Colors.red.shade50
                    : AppColors.brandBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                entry.icon,
                size: 18,
                color: iconColor,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                  if (hasValue) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.value!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (entry.trailing != null) entry.trailing!,
            if (showChevron)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: entry.isDestructive
                    ? Colors.red.shade300
                    : AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

TextStyle dashboardSectionTitleStyle() {
  return GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.brandBlue,
  );
}

class DashboardMenuSection extends StatelessWidget {
  const DashboardMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<DashboardMenuEntry> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s8),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: dashboardSectionTitleStyle(),
          ),
        ),
        PickupDashboardCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                DashboardMenuTile(entry: items[i]),
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                    indent: 64,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
