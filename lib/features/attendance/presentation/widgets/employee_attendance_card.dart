import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/attendance_theme.dart';

class EmployeeAttendanceCard extends StatelessWidget {
  const EmployeeAttendanceCard({
    super.key,
    required this.record,
    this.onTap,
  });

  final EmployeeAttendanceRecord record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AttendanceTheme.cardDecoration.borderRadius,
        child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: AttendanceTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  record.employeeName.isNotEmpty
                      ? record.employeeName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.employeeName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(record.role, style: AttendanceTheme.labelStyle),
                  ],
                ),
              ),
              _AttendanceStatusBadge(status: record.status),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(
                child: _TimeTile(
                  label: 'Masuk',
                  value: record.clockIn ?? '-',
                  icon: Icons.login,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _TimeTile(
                  label: 'Pulang',
                  value: record.clockOut ?? '-',
                  icon: Icons.logout,
                ),
              ),
            ],
          ),
          if (record.fingerprintDeviceId != null) ...[
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                const Icon(
                  Icons.fingerprint,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.s4),
                Text(
                  'EPPOS • ${record.fingerprintDeviceId}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
        ),
      ),
    );
  }
}

class _AttendanceStatusBadge extends StatelessWidget {
  const _AttendanceStatusBadge({required this.status});

  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status.textColor,
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.dashboardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AttendanceTheme.labelStyle),
                Text(value, style: AttendanceTheme.valueStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
