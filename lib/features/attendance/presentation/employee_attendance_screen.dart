import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/attendance/data/dummy_attendance_data.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/attendance_theme.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/widgets/attendance_summary_grid.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/widgets/employee_attendance_card.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/widgets/eppos_integration_card.dart';

class EmployeeAttendanceScreen extends StatelessWidget {
  const EmployeeAttendanceScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Kehadiran Karyawan',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s32,
        ),
        children: [
          const AttendanceSummaryGrid(summary: attendanceSummary),
          const SizedBox(height: AppSpacing.s16),
          EpposIntegrationCard(syncStatus: epposSyncStatus),
          const SizedBox(height: AppSpacing.s24),
          Text('Daftar Kehadiran', style: AttendanceTheme.sectionTitleStyle),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Data absensi hari ini — siap disinkronkan dengan mesin fingerprint EPPOS.',
            style: AttendanceTheme.labelStyle,
          ),
          const SizedBox(height: AppSpacing.s16),
          for (var i = 0; i < dummyAttendanceRecords.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s12),
            EmployeeAttendanceCard(record: dummyAttendanceRecords[i]),
          ],
        ],
      ),
    );
  }
}
