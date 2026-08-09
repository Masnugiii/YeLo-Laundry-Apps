import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_master/data/dummy_employees.dart';
import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/employee_master_theme.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/widgets/employee_badges.dart';

class EmployeeDetailScreen extends StatelessWidget {
  const EmployeeDetailScreen({
    super.key,
    required this.employeeId,
  });

  final String employeeId;

  @override
  Widget build(BuildContext context) {
    final employee = findEmployeeById(employeeId);

    if (employee == null) {
      return Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        appBar: _buildAppBar('Detail Karyawan'),
        body: Center(
          child: Text(
            'Karyawan tidak ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: _buildAppBar('Detail Karyawan'),
      body: ListView(
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
                _DetailRow(label: 'Employee ID', value: employee.employeeCode),
                _DetailRow(label: 'Gender', value: employee.gender.label),
                _DetailRow(
                  label: 'Date of Birth',
                  value: formatEmployeeDate(employee.dateOfBirth),
                ),
                _DetailRow(
                  label: 'Phone Number (WhatsApp)',
                  value: employee.phone,
                ),
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
                _DetailRow(
                  label: 'Emergency Contact',
                  value: employee.emergencyContact,
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
                if (employee.kpiScore != null)
                  _DetailRow(
                    label: 'Current KPI Score',
                    value: '${employee.kpiScore}',
                  ),
                if (employee.currentPoint != null)
                  _DetailRow(
                    label: 'Current Point',
                    value: '${employee.currentPoint}',
                  ),
                if (employee.monthlyRanking != null)
                  _DetailRow(
                    label: 'Monthly Ranking',
                    value: '#${employee.monthlyRanking}',
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          _SectionCard(
            title: 'Quick Actions',
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.edit_outlined,
                  label: 'Edit Employee',
                  onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.divider),
                _ActionTile(
                  icon: Icons.lock_reset_outlined,
                  label: 'Reset Login',
                  onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.divider),
                _ActionTile(
                  icon: Icons.person_off_outlined,
                  label: 'Deactivate Employee',
                  onTap: () {},
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
