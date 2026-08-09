import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/attendance_theme.dart';

void showAttendanceDetailSheet(
  BuildContext context, {
  required EmployeeAttendanceRecord record,
  required Map<String, dynamic> detail,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _AttendanceDetailSheet(
      record: record,
      detail: detail,
    ),
  );
}

class _AttendanceDetailSheet extends StatelessWidget {
  const _AttendanceDetailSheet({
    required this.record,
    required this.detail,
  });

  final EmployeeAttendanceRecord record;
  final Map<String, dynamic> detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Detail Kehadiran',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(record.employeeName, style: AttendanceTheme.sectionTitleStyle),
          const SizedBox(height: AppSpacing.s16),
          _DetailRow(label: 'Kode', value: record.role),
          _DetailRow(label: 'Status', value: detail['displayStatus'] as String? ?? record.status.label),
          _DetailRow(label: 'Check In', value: record.clockIn ?? '-'),
          _DetailRow(label: 'Check Out', value: record.clockOut ?? '-'),
          _DetailRow(
            label: 'Jam Kerja',
            value: '${detail['workingHours'] ?? 0} jam',
          ),
          _DetailRow(
            label: 'Terlambat',
            value: '${detail['lateMinutes'] ?? 0} menit',
          ),
          _DetailRow(
            label: 'Lembur',
            value: '${detail['overtimeMinutes'] ?? 0} menit',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AttendanceTheme.labelStyle)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
