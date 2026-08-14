import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_page_header.dart';
import 'package:yelo_laundry_customer/features/address/data/address_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class AddressListScreen extends ConsumerStatefulWidget {
  const AddressListScreen({super.key});

  @override
  ConsumerState<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends ConsumerState<AddressListScreen> {
  List<CustomerAddress> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final customerId = ref.read(sessionProvider).id;
      final addresses = await ref.read(addressRepositoryProvider).list(customerId);
      if (mounted) setState(() => _addresses = addresses);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    final customerId = ref.read(sessionProvider).id;
    await ref.read(addressRepositoryProvider).delete(customerId, id);
    await _load();
  }

  Future<void> _openAddAddress() async {
    await context.push('/addresses/add');
    await _load();
  }

  Widget _buildAddressCard(CustomerAddress address) {
    return PickupDashboardCard(
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: InkWell(
        onTap: () async {
          await context.push('/addresses/${address.id}/edit');
          await _load();
        },
        onLongPress: () => _delete(address.id),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.brandBlue,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.recipientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (address.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Default',
                            style: _poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandBlue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    address.fullAddress,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: _poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandBlue),
      );
    }

    if (_addresses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          PickupDashboardCard(
            child: Text(
              'Belum ada alamat tersimpan.',
              textAlign: TextAlign.center,
              style: _poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.brandBlue,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: _addresses.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.s12),
        itemBuilder: (context, index) => _buildAddressCard(_addresses[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          DashboardPageHeader(
            title: 'Alamat',
            actions: [
              IconButton(
                onPressed: _openAddAddress,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
