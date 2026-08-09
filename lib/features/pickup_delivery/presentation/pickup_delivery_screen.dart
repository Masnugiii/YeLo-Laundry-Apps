import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_menu_badge_actions.dart';
import 'package:yelo_laundry_erp/features/pickup_delivery/data/pickup_delivery_mapper.dart';
import 'package:yelo_laundry_erp/features/pickup_delivery/models/pickup_delivery_request.dart';
import 'package:yelo_laundry_erp/features/pickup_delivery/presentation/widgets/pickup_delivery_card.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class PickupDeliveryScreen extends ConsumerStatefulWidget {
  const PickupDeliveryScreen({super.key});

  @override
  ConsumerState<PickupDeliveryScreen> createState() =>
      _PickupDeliveryScreenState();
}

class _PickupDeliveryScreenState extends ConsumerState<PickupDeliveryScreen> {
  static const _filters = PickupDeliveryFilter.values;

  final _searchController = TextEditingController();
  PickupDeliveryFilter _selectedFilter = PickupDeliveryFilter.all;
  Map<String, dynamic>? _dashboard;
  bool _loadingDashboard = true;
  List<PickupDeliveryRequest> _requests = [];
  bool _loadingRequests = true;
  String? _requestError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = ref.read(userRoleProvider);
      markPickupDeliveryBadgeRead(ref, role);
      _loadDashboard();
      _loadRequests();
    });
  }

  Future<void> _loadRequests() async {
    setState(() {
      _loadingRequests = true;
      _requestError = null;
    });

    try {
      final repository = ref.read(pickupDeliveryRepositoryProvider);
      final results = await Future.wait([
        repository.fetchPickups(),
        repository.fetchDeliveries(),
      ]);

      final requests = [
        ...results[0].map(mapPickupDeliveryJob),
        ...results[1].map(mapPickupDeliveryJob),
      ]..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

      if (mounted) {
        setState(() {
          _requests = requests;
          _loadingRequests = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingRequests = false;
          _requestError = 'Gagal memuat data pickup & delivery.';
        });
      }
    }
  }

  Future<void> _loadDashboard() async {
    setState(() => _loadingDashboard = true);

    try {
      final data =
          await ref.read(pickupDeliveryRepositoryProvider).fetchDashboard();
      if (mounted) {
        setState(() {
          _dashboard = data;
          _loadingDashboard = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingDashboard = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PickupDeliveryRequest> _filteredRequests() {
    final normalizedQuery = _searchController.text.trim().toLowerCase();

    return _requests.where((request) {
      final matchesSearch = normalizedQuery.isEmpty ||
          request.customerName.toLowerCase().contains(normalizedQuery) ||
          request.customerPhone.toLowerCase().contains(normalizedQuery);

      if (!matchesSearch) {
        return false;
      }

      return switch (_selectedFilter) {
        PickupDeliveryFilter.all => true,
        PickupDeliveryFilter.pickup => request.status.isPickupRelated,
        PickupDeliveryFilter.delivery => request.status.isDeliveryRelated,
        PickupDeliveryFilter.today => request.isToday,
        PickupDeliveryFilter.completed => request.status.isCompleted,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final requests = _filteredRequests();

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Pickup & Delivery',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          if (_loadingDashboard)
            const LinearProgressIndicator(
              minHeight: 3,
              color: AppColors.accent,
              backgroundColor: AppColors.divider,
            )
          else if (_dashboard != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s12,
                AppSpacing.s20,
                AppSpacing.s8,
              ),
              child: _PickupDeliveryDashboardSummary(dashboard: _dashboard!),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s12,
              AppSpacing.s20,
              AppSpacing.s12,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Cari pelanggan atau nomor HP',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;

                return SelectableChip(
                  label: filter.label,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedFilter = filter),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Expanded(
            child: _loadingRequests
                ? const ApiLoadingView()
                : _requestError != null
                    ? ApiErrorView(
                        message: _requestError!,
                        onRetry: _loadRequests,
                      )
                    : requests.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada permintaan pickup & delivery',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.wait([
                        _loadDashboard(),
                        _loadRequests(),
                      ]);
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s20,
                        AppSpacing.s8,
                        AppSpacing.s20,
                        AppSpacing.s32,
                      ),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return PickupDeliveryCard(
                          request: request,
                          onContactCustomer: () {},
                          onViewDetail: () {},
                          onOpenMaps: () {},
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PickupDeliveryDashboardSummary extends StatelessWidget {
  const _PickupDeliveryDashboardSummary({required this.dashboard});

  final Map<String, dynamic> dashboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              label: 'Pickup',
              value: '${dashboard['pickupRequested'] ?? 0}',
            ),
          ),
          Expanded(
            child: _SummaryItem(
              label: 'Siap Kirim',
              value: '${dashboard['readyForDelivery'] ?? 0}',
            ),
          ),
          Expanded(
            child: _SummaryItem(
              label: 'Terkirim',
              value: '${dashboard['deliveredToday'] ?? 0}',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
