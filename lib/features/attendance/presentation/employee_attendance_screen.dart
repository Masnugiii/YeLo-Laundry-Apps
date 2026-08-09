import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/attendance/data/attendance_mapper.dart';
import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/attendance_theme.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/widgets/attendance_detail_sheet.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/widgets/attendance_summary_grid.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/widgets/employee_attendance_card.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class EmployeeAttendanceScreen extends ConsumerStatefulWidget {
  const EmployeeAttendanceScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  ConsumerState<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState
    extends ConsumerState<EmployeeAttendanceScreen> {
  bool _loading = true;
  String? _error;
  var _summary = const AttendanceSummary(
    presentToday: 0,
    lateToday: 0,
    leaveToday: 0,
    notCheckedIn: 0,
  );
  List<EmployeeAttendanceRecord> _records = const [];

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repository = ref.read(attendanceRepositoryProvider);
      final results = await Future.wait([
        repository.fetchDashboard(),
        repository.fetchHistory(limit: 50),
      ]);

      if (!mounted) return;

      setState(() {
        _summary = mapAttendanceSummary(results[0] as Map<String, dynamic>);
        _records = (results[1] as List<Map<String, dynamic>>)
            .map(mapEmployeeAttendanceRecord)
            .toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = messageFromError(error);
      });
    }
  }

  Future<void> _openDetail(EmployeeAttendanceRecord record) async {
    try {
      final detail = await ref
          .read(attendanceRepositoryProvider)
          .fetchDetail(record.id);
      if (!mounted) return;
      showAttendanceDetailSheet(
        context,
        record: record,
        detail: detail,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(messageFromError(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
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
      body: _loading
          ? const ApiLoadingView()
          : _error != null
              ? ApiErrorView(
                  message: _error!,
                  onRetry: _loadAttendance,
                )
              : RefreshIndicator(
                  onRefresh: _loadAttendance,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      AppSpacing.s20,
                      AppSpacing.s20,
                      AppSpacing.s32,
                    ),
                    children: [
                      AttendanceSummaryGrid(summary: _summary),
                      const SizedBox(height: AppSpacing.s24),
                      Text(
                        'Daftar Kehadiran',
                        style: AttendanceTheme.sectionTitleStyle,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        'Data absensi dari sistem backend.',
                        style: AttendanceTheme.labelStyle,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      if (_records.isEmpty)
                        Center(
                          child: Text(
                            'Belum ada data kehadiran.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      else
                        for (var i = 0; i < _records.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.s12),
                          EmployeeAttendanceCard(
                            record: _records[i],
                            onTap: () => _openDetail(_records[i]),
                          ),
                        ],
                    ],
                  ),
                ),
    );
  }
}
