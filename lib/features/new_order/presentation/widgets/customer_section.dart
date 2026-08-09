import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer/data/dummy_customers.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/new_order_section_card.dart';

class CustomerSection extends StatelessWidget {
  const CustomerSection({
    super.key,
    required this.selectedCustomer,
    required this.onCustomerSelected,
  });

  final Customer? selectedCustomer;
  final ValueChanged<Customer> onCustomerSelected;

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => _showCustomerPicker(context),
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

  Future<void> _showCustomerPicker(BuildContext context) async {
    final customer = await showModalBottomSheet<Customer>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s20),
            itemCount: dummyCustomers.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final customer = dummyCustomers[index];
              return ListTile(
                title: Text(
                  customer.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(customer.phone),
                onTap: () => Navigator.pop(context, customer),
              );
            },
          ),
        );
      },
    );

    if (customer != null) {
      onCustomerSelected(customer);
    }
  }
}
