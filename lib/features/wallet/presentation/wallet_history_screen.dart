import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer/data/dummy_customers.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/widgets/customer_fab.dart';
import 'package:yelo_laundry_erp/features/wallet/data/dummy_wallet_transactions.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_transaction_tile.dart';

class WalletHistoryScreen extends StatelessWidget {
  const WalletHistoryScreen({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  Widget build(BuildContext context) {
    Customer? customer;
    for (final item in dummyCustomers) {
      if (item.id == customerId) {
        customer = item;
        break;
      }
    }
    final transactions = walletTransactionsForCustomer(customerId);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      floatingActionButton: const CustomerFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Riwayat Deposit',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: transactions.isEmpty
          ? Center(
              child: Text(
                'Belum ada riwayat transaksi',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              children: [
                if (customer != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                    child: Text(
                      customer.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                for (var i = 0; i < transactions.length; i++)
                  WalletTransactionTile(
                    transaction: transactions[i],
                    showDivider: i < transactions.length - 1,
                  ),
              ],
            ),
    );
  }
}
