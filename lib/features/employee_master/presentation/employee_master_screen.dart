import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/employee_master_theme.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/widgets/add_employee_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/widgets/employee_card.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/widgets/employee_summary_grid.dart';
import 'package:yelo_laundry_erp/features/employee_master/providers/employee_providers.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class EmployeeMasterScreen extends ConsumerStatefulWidget {
  const EmployeeMasterScreen({super.key});

  @override
  ConsumerState<EmployeeMasterScreen> createState() =>
      _EmployeeMasterScreenState();
}

class _EmployeeMasterScreenState extends ConsumerState<EmployeeMasterScreen> {
  static const _filters = EmployeeFilter.values;

  final _searchController = TextEditingController();
  EmployeeFilter _selectedFilter = EmployeeFilter.all;
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Employee> _filterEmployees(List<Employee> employees) {
    return filterEmployees(
      employees: employees,
      query: _search,
      filter: _selectedFilter,
    );
  }

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
    final employeesAsync = ref.watch(employeeListProvider(_search));
    final statisticsAsync = ref.watch(employeeStatisticsProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: _buildAppBar(),
      body: employeesAsync.when(
        loading: () => const ApiLoadingView(),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.invalidate(employeeListProvider(_search)),
        ),
        data: (employees) {
          final filtered = _filterEmployees(employees);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(employeeListProvider(_search));
              ref.invalidate(employeeStatisticsProvider);
              await ref.read(employeeListProvider(_search).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              children: [
                statisticsAsync.when(
                  loading: () => const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => EmployeeSummaryGrid(
                    summary: computeEmployeeSummary(employees),
                  ),
                  data: (summary) => EmployeeSummaryGrid(summary: summary),
                ),
                const SizedBox(height: AppSpacing.s20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => showAddEmployeeBottomSheet(
                          context,
                          ref: ref,
                          onSaved: () {
                            ref.invalidate(employeeListProvider(_search));
                            ref.invalidate(employeeStatisticsProvider);
                          },
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
                  onChanged: (value) => setState(() => _search = value.trim()),
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
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.s32),
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
          );
        },
      ),
    );
  }
}
