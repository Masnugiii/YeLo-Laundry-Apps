import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_master/data/dummy_employees.dart';
import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/employee_master_theme.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/widgets/add_employee_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/widgets/employee_card.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/widgets/employee_summary_grid.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class EmployeeMasterScreen extends StatefulWidget {
  const EmployeeMasterScreen({super.key});

  @override
  State<EmployeeMasterScreen> createState() => _EmployeeMasterScreenState();
}

class _EmployeeMasterScreenState extends State<EmployeeMasterScreen> {
  static const _filters = EmployeeFilter.values;

  final _searchController = TextEditingController();
  late List<Employee> _employees;
  EmployeeFilter _selectedFilter = EmployeeFilter.all;

  @override
  void initState() {
    super.initState();
    _employees = List<Employee>.from(initialDummyEmployees());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addEmployee(Employee employee) {
    addEmployeeToStore(employee);
    setState(() => _employees = List<Employee>.from(initialDummyEmployees()));
  }

  List<Employee> get _filteredEmployees => filterEmployees(
        employees: _employees,
        query: _searchController.text,
        filter: _selectedFilter,
      );

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.onPrimary),
      title: Text(
        'Master Karyawan',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEmployees;
    final summary = computeEmployeeSummary(_employees);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              children: [
                EmployeeSummaryGrid(summary: summary),
                const SizedBox(height: AppSpacing.s20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => showAddEmployeeBottomSheet(
                          context,
                          onSaved: _addEmployee,
                          nextEmployeeNumber: _employees.length + 1,
                        ),
                        icon: const Icon(Icons.add, color: AppColors.onPrimary),
                        label: Text(
                          'Tambah Karyawan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, color: AppColors.primary),
                      label: Text(
                        'Filter',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16,
                          vertical: 14,
                        ),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  'Search Employee',
                  style: EmployeeMasterTheme.labelStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  decoration: EmployeeMasterTheme.searchDecoration(
                    'Cari nama, nomor HP, atau role...',
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.s8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      return SelectableChip(
                        label: filter.label,
                        isSelected: filter == _selectedFilter,
                        onTap: () => setState(() => _selectedFilter = filter),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                for (var i = 0; i < filtered.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.s12),
                  EmployeeCard(
                    employee: filtered[i],
                    onTap: () => context.push(
                      '/employee-master/${filtered[i].id}',
                    ),
                  ),
                ],
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s32),
                    child: Center(
                      child: Text(
                        'Karyawan tidak ditemukan',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
