import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';
import 'package:yelo_laundry_erp/features/attendance/models/personal_attendance_models.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/attendance_theme.dart';

class BinatuAttendanceProfileCard extends StatelessWidget {
  const BinatuAttendanceProfileCard({
    super.key,
    required this.profile,
  });

  final PersonalAttendanceProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: AttendanceTheme.cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  profile.position,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BinatuTodayAttendanceCard extends StatelessWidget {
  const BinatuTodayAttendanceCard({
    super.key,
    required this.today,
  });

  final PersonalAttendanceDay today;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: AttendanceTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kehadiran Hari Ini',
                  style: AttendanceTheme.sectionTitleStyle.copyWith(fontSize: 16),
                ),
              ),
              _StatusBadge(status: today.status),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          _TimeRow(
            label: "Today's Check In",
            value: today.checkIn ?? '-',
            icon: Icons.login,
          ),
          const SizedBox(height: AppSpacing.s12),
          _TimeRow(
            label: "Today's Check Out",
            value: today.checkOut ?? '-',
            icon: Icons.logout,
          ),
          const SizedBox(height: AppSpacing.s12),
          _TimeRow(
            label: 'Working Hours',
            value: today.workingHours ?? '-',
            icon: Icons.schedule_outlined,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class BinatuEpposReadyCard extends StatelessWidget {
  const BinatuEpposReadyCard({
    super.key,
    this.deviceId,
  });

  final String? deviceId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.fingerprint, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              deviceId == null
                  ? 'Siap terhubung dengan sistem fingerprint EPPOS.'
                  : 'Terhubung ke EPPOS • $deviceId',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

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

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Text(label, style: AttendanceTheme.labelStyle),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
