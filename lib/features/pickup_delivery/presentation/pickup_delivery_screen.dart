import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_menu_badge_actions.dart';
import 'package:yelo_laundry_erp/features/pickup_delivery/data/dummy_pickup_delivery_requests.dart';
import 'package:yelo_laundry_erp/features/pickup_delivery/models/pickup_delivery_request.dart';
import 'package:yelo_laundry_erp/features/pickup_delivery/presentation/widgets/pickup_delivery_card.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = ref.read(userRoleProvider);
      markPickupDeliveryBadgeRead(ref, role);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requests = filterPickupDeliveryRequests(
      query: _searchController.text,
      filter: _selectedFilter,
    );

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
            child: requests.isEmpty
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
                : ListView.builder(
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
        ],
      ),
    );
  }
}
