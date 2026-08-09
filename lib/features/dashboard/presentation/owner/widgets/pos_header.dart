import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/utils/date_display_helper.dart';
import 'package:yelo_laundry_erp/core/utils/greeting_helper.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/dashboard_employee.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_employee_provider.dart';

class PosHeader extends ConsumerWidget {
  const PosHeader({
    super.key,
    this.employeeOverride,
  });

  /// When set, overrides [dashboardEmployeeProvider] for role-specific headers.
  final DashboardEmployee? employeeOverride;

  static const _logoAsset = 'assets/images/Logo_WithBackground.png';
  static const _logoHeight = 100.0;
  static const _white70 = Color(0xB3FFFFFF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardEmployee employee =
        employeeOverride ?? ref.watch(dashboardEmployeeProvider);
    final greeting = GreetingHelper.greeting();
    final currentDate = DateDisplayHelper.currentLongIndonesianDate();

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                    height: 1.3,
                  ),
                ),
                Text(
                  employee.greetingTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  employee.roleLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _white70,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  currentDate,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: _white70,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Image.asset(
            _logoAsset,
            height: _logoHeight,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
