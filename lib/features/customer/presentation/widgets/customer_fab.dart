import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/widgets/add_customer_bottom_sheet.dart';

class CustomerFab extends StatelessWidget {
  const CustomerFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showAddCustomerBottomSheet(context),
      tooltip: 'Tambah Customer',
      elevation: 6,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      child: const Icon(Icons.add),
    );
  }
}
