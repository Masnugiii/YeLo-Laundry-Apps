import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/new_order_section_card.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class CustomerSection extends ConsumerWidget {
  const CustomerSection({
    super.key,
    required this.selectedCustomer,
    required this.onCustomerSelected,
  });

  final Customer? selectedCustomer;
  final ValueChanged<Customer> onCustomerSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NewOrderSectionCard(
      title: 'Pelanggan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (selectedCustomer != null) ...[
            Text(
              selectedCustomer!.name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              selectedCustomer!.phone,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
          ],
          OutlinedButton(
            onPressed: () => _openAddCustomer(context),
            child: const Text('+ Tambahkan Pelanggan'),
          ),
          const SizedBox(height: AppSpacing.s12),
          FilledButton.tonal(
            onPressed: () => _showCustomerPicker(context, ref),
            child: const Text('Pilih Pelanggan'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddCustomer(BuildContext context) async {
    final customer = await context.push<Customer>('/customer/new');
    if (customer != null) {
      onCustomerSelected(customer);
    }
  }

  Future<void> _showCustomerPicker(BuildContext context, WidgetRef ref) async {
    final customer = await showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _CustomerPickerSheet(
          onSelected: (value) => Navigator.pop(context, value),
        );
      },
    );

    if (customer != null) {
      onCustomerSelected(customer);
    }
  }
}

class _CustomerPickerSheet extends ConsumerStatefulWidget {
  const _CustomerPickerSheet({required this.onSelected});

  final ValueChanged<Customer> onSelected;

  @override
  ConsumerState<_CustomerPickerSheet> createState() =>
      _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends ConsumerState<_CustomerPickerSheet> {
  final _searchController = TextEditingController();
  List<Customer> _customers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers({String? search}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ref
          .read(customerRepositoryProvider)
          .fetchCustomers(limit: 50, search: search);
      if (!mounted) return;
      setState(() {
        _customers = response.items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat pelanggan.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari nama atau telepon',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) => _loadCustomers(search: value),
            ),
            const SizedBox(height: AppSpacing.s12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.s24),
                child: ApiLoadingView(),
              )
            else if (_error != null)
              ApiErrorView(message: _error!, onRetry: () => _loadCustomers())
            else if (_customers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: Text(
                  'Tidak ada pelanggan.',
                  style: GoogleFonts.poppins(color: AppColors.textSecondary),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _customers.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final customer = _customers[index];
                    return ListTile(
                      title: Text(
                        customer.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(customer.phone),
                      onTap: () => widget.onSelected(customer),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
