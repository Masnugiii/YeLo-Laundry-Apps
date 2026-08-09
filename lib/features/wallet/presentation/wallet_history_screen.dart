import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/widgets/customer_fab.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_transaction_tile.dart';
import 'package:yelo_laundry_erp/features/wallet/providers/wallet_providers.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class WalletHistoryScreen extends ConsumerWidget {
  const WalletHistoryScreen({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(walletTransactionsProvider(customerId));
    final walletAsync = ref.watch(customerWalletProvider(customerId));

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
      body: transactionsAsync.when(
        loading: () => const ApiLoadingView(),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () =>
              ref.invalidate(walletTransactionsProvider(customerId)),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Text(
                'Belum ada riwayat transaksi',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(walletTransactionsProvider(customerId));
              ref.invalidate(customerWalletProvider(customerId));
              await ref.read(walletTransactionsProvider(customerId).future);
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
                walletAsync.maybeWhen(
                  data: (wallet) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                    child: Text(
                      'Saldo saat ini: Rp${wallet.balance.round()}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                for (var i = 0; i < transactions.length; i++)
                  WalletTransactionTile(
                    transaction: transactions[i],
                    showDivider: i < transactions.length - 1,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
