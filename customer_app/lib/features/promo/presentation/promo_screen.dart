import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';
import 'package:yelo_laundry_customer/features/promo/models/customer_promo.dart';
import 'package:yelo_laundry_customer/features/promo/presentation/widgets/promo_card.dart';
import 'package:yelo_laundry_customer/features/promo/providers/promo_providers.dart';

class PromoScreen extends ConsumerStatefulWidget {
  const PromoScreen({super.key});

  @override
  ConsumerState<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends ConsumerState<PromoScreen> {
  List<CustomerPromo> _promos = [];
  bool _loading = true;
  bool _apiAvailable = true;
  String? _error;

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ref.read(promoRepositoryProvider).fetchActivePromos();
      if (!mounted) return;
      setState(() {
        _promos = result.promos;
        _apiAvailable = result.apiAvailable;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDetail(CustomerPromo promo) {
    context.push('/promo/${promo.id}', extra: promo);
  }

  void _usePromo(CustomerPromo promo) {
    ref.read(selectedPromoProvider.notifier).select(promo);
    context.go('/pickup');
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s8,
            AppSpacing.s8,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.go('/home'),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  'Promo',
                  style: _poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return PickupDashboardCard(
      child: Column(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Belum ada promo',
            style: _poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Pantau terus untuk mendapatkan promo menarik dari Yelo Laundry.',
            style: _poppins(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (!_apiAvailable) ...[
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Endpoint promo customer belum tersedia di server.',
              style: _poppins(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loading
                ? const ApiLoadingView(message: 'Memuat promo...')
                : _error != null
                    ? ApiErrorView(message: _error!, onRetry: _load)
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.brandBlue,
                        child: _promos.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(AppSpacing.s16),
                                children: [_buildEmptyState()],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.s16,
                                  AppSpacing.s12,
                                  AppSpacing.s16,
                                  AppSpacing.s16,
                                ),
                                itemCount: _promos.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.s12),
                                itemBuilder: (context, index) {
                                  final promo = _promos[index];
                                  return PromoCard(
                                    promo: promo,
                                    onTap: () => _openDetail(promo),
                                    onUse: promo.isUsable
                                        ? () => _usePromo(promo)
                                        : null,
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
