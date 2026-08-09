import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/employee_master_theme.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/widgets/employee_badges.dart';
import 'package:yelo_laundry_erp/features/employee_master/providers/employee_providers.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  const EmployeeDetailScreen({
    super.key,
    required this.employeeId,
  });

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeDetailProvider(employeeId));

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: _buildAppBar('Detail Karyawan'),
      body: employeeAsync.when(
        loading: () => const ApiLoadingView(),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.invalidate(employeeDetailProvider(employeeId)),
        ),
        data: (employee) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s20,
            AppSpacing.s20,
            AppSpacing.s32,
          ),
          children: [
            _SectionCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      employee.initials,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    employee.fullName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      EmployeeRoleBadge(role: employee.role),
                      EmployeeStatusBadge(status: employee.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  _DetailRow(
                    label: 'Employee ID',
                    value: employee.employeeCode,
                  ),
                  _DetailRow(label: 'Phone Number', value: employee.phone),
                  _DetailRow(label: 'Address', value: employee.address),
                  _DetailRow(label: 'Role', value: employee.role.label),
                  _DetailRow(
                    label: 'Employment Status',
                    value: employee.status.label,
                  ),
                  _DetailRow(
                    label: 'Join Date',
                    value: formatEmployeeDate(employee.joinDate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            _SectionCard(
              title: 'Work Information',
              child: Column(
                children: [
                  _DetailRow(label: 'Branch', value: employee.branch),
                  _DetailRow(label: 'Position', value: employee.position),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.onPrimary),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    this.title,
    required this.child,
  });

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: EmployeeMasterTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: EmployeeMasterTheme.sectionTitleStyle),
            const SizedBox(height: AppSpacing.s16),
          ],
          child,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: EmployeeMasterTheme.labelStyle),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: EmployeeMasterTheme.valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}
