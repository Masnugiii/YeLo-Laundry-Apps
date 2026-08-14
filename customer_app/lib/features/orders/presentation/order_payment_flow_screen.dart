import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_method.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_status.dart';
import 'package:yelo_laundry_customer/features/pickup/models/customer_payment_config.dart';
import 'package:yelo_laundry_customer/features/pickup/models/laundry_checkout_draft.dart';
import 'package:yelo_laundry_customer/features/wallet/data/wallet_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/checkout_payment_detail_section.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/payment_method_selection_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

enum _OrderPaymentStep { payment, paymentDetail, confirm, status }

class OrderPaymentFlowScreen extends ConsumerStatefulWidget {
  const OrderPaymentFlowScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderPaymentFlowScreen> createState() =>
      _OrderPaymentFlowScreenState();
}

class _OrderPaymentFlowScreenState extends ConsumerState<OrderPaymentFlowScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  OrderDetail? _order;
  String _paymentMethodCode = CheckoutPaymentMethods.yeloWallet;
  double? _walletBalance;
  CustomerPaymentConfig _paymentConfig = CustomerPaymentConfig.empty;
  CheckoutPaymentStatus? _paymentStatus;
  _OrderPaymentStep _step = _OrderPaymentStep.payment;
  bool _loading = true;
  bool _submitting = false;
  bool _checkingPayment = false;
  String? _error;

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
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = ref.read(sessionProvider);
      final orderFuture =
          ref.read(orderRepositoryProvider).getOrder(widget.orderId);
      final configFuture =
          ref.read(paymentConfigRepositoryProvider).fetchPaymentConfig();
      final walletFuture =
          ref.read(walletRepositoryProvider).getWallet(session.id);

      final results = await Future.wait([orderFuture, configFuture, walletFuture]);

      if (!mounted) return;
      final order = results[0] as OrderDetail;
      final config = results[1] as CustomerPaymentConfig;
      final wallet = results[2] as WalletSummary;

      setState(() {
        _order = order;
        _paymentConfig = config;
        _walletBalance = wallet.balance;
        final available = config.availableMethodCodes;
        if (available.isNotEmpty && !available.contains(_paymentMethodCode)) {
          _paymentMethodCode = available.first;
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _grandTotal => _order?.grandTotal.round() ?? 0;

  bool get _canContinueFromPayment {
    if (_paymentMethodCode == CheckoutPaymentMethods.yeloWallet &&
        _walletBalance != null &&
        _walletBalance! < _grandTotal) {
      return false;
    }
    if (_paymentMethodCode == CheckoutPaymentMethods.qris ||
        _paymentMethodCode == CheckoutPaymentMethods.bankTransfer) {
      return isPaymentDetailReady(_paymentMethodCode, _paymentConfig);
    }
    return true;
  }

  void _handleBack() {
    if (_step == _OrderPaymentStep.status) {
      if (_paymentStatus?.phase == CheckoutPaymentPhase.failed) {
        setState(() => _step = _OrderPaymentStep.payment);
        return;
      }
      context.pop();
      return;
    }
    if (_step == _OrderPaymentStep.confirm) {
      if (_paymentMethodCode == CheckoutPaymentMethods.qris ||
          _paymentMethodCode == CheckoutPaymentMethods.bankTransfer) {
        setState(() => _step = _OrderPaymentStep.paymentDetail);
      } else {
        setState(() => _step = _OrderPaymentStep.payment);
      }
      return;
    }
    if (_step == _OrderPaymentStep.paymentDetail) {
      setState(() => _step = _OrderPaymentStep.payment);
      return;
    }
    context.pop();
  }

  void _continueFromPayment() {
    if (_paymentMethodCode == CheckoutPaymentMethods.qris ||
        _paymentMethodCode == CheckoutPaymentMethods.bankTransfer) {
      setState(() => _step = _OrderPaymentStep.paymentDetail);
      return;
    }
    setState(() => _step = _OrderPaymentStep.confirm);
  }

  Future<void> _confirmPayment() async {
    setState(() => _submitting = true);
    try {
      final status = await ref
          .read(laundryCheckoutRepositoryProvider)
          .requestOrderPayment(
            orderId: widget.orderId,
            paymentMethodCode: _paymentMethodCode,
          );
      if (!mounted) return;
      setState(() {
        _paymentStatus = status;
        _step = _OrderPaymentStep.status;
      });
    } on CheckoutApiException catch (error) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pembayaran belum dapat diproses'),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _checkPaymentStatus() async {
    setState(() => _checkingPayment = true);
    try {
      final status = await ref
          .read(laundryCheckoutRepositoryProvider)
          .refreshPaymentStatus(widget.orderId);
      if (!mounted) return;
      setState(() => _paymentStatus = status);
      if (status.phase == CheckoutPaymentPhase.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil dikonfirmasi.')),
        );
        context.pop(true);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _checkingPayment = false);
    }
  }

  Widget _buildHeader(String subtitle) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _handleBack,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Bayar Pesanan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s4),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.s8),
                child: Text(
                  subtitle,
                  style: _poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.brandBlue,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandBlue,
                ),
              )
            : Text(
                label,
                style: _poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlue,
                ),
              ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: _poppins(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _poppins(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? AppColors.brandBlue : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s24,
      ),
      children: [
        PaymentMethodSelectionCard(
          selectedCode: _paymentMethodCode,
          onSelected: (code) => setState(() => _paymentMethodCode = code),
          paymentConfig: _paymentConfig,
          walletBalance: _walletBalance,
          orderTotal: _grandTotal,
        ),
        const SizedBox(height: AppSpacing.s16),
        _primaryButton(
          label: _paymentMethodCode == CheckoutPaymentMethods.yeloWallet
              ? 'Lanjutkan ke Konfirmasi'
              : 'Lanjutkan ke Detail Pembayaran',
          onPressed: _canContinueFromPayment ? _continueFromPayment : null,
        ),
      ],
    );
  }

  Widget _buildPaymentDetailStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s24,
      ),
      children: [
        CheckoutPaymentDetailSection(
          paymentMethodCode: _paymentMethodCode,
          totalAmount: _grandTotal,
          paymentConfig: _paymentConfig,
        ),
        const SizedBox(height: AppSpacing.s16),
        _primaryButton(
          label: 'Lanjutkan ke Konfirmasi',
          onPressed: isPaymentDetailReady(_paymentMethodCode, _paymentConfig)
              ? () => setState(() => _step = _OrderPaymentStep.confirm)
              : null,
        ),
      ],
    );
  }

  Widget _buildConfirmStep() {
    final order = _order!;
    final status = CheckoutPaymentStatus.fromRaw(order.paymentStatus);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s24,
      ),
      children: [
        PickupDashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Nomor Order', order.orderNumber),
              const SizedBox(height: AppSpacing.s8),
              _summaryRow('Status Pembayaran', status.displayLabel),
              const SizedBox(height: AppSpacing.s8),
              _summaryRow(
                'Metode Pembayaran',
                CheckoutPaymentMethods.label(_paymentMethodCode),
              ),
              const SizedBox(height: AppSpacing.s12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.s12),
              _summaryRow('Total', _currency.format(order.grandTotal), isTotal: true),
            ],
          ),
        ),
        if (_paymentMethodCode == CheckoutPaymentMethods.qris ||
            _paymentMethodCode == CheckoutPaymentMethods.bankTransfer) ...[
          const SizedBox(height: AppSpacing.s12),
          CheckoutPaymentDetailSection(
            paymentMethodCode: _paymentMethodCode,
            totalAmount: _grandTotal,
            paymentConfig: _paymentConfig,
          ),
        ],
        const SizedBox(height: AppSpacing.s16),
        _primaryButton(
          label: 'Konfirmasi Pembayaran',
          onPressed: _confirmPayment,
          loading: _submitting,
        ),
      ],
    );
  }

  Widget _buildStatusStep() {
    final order = _order!;
    final status = _paymentStatus ?? CheckoutPaymentStatus.fromRaw(order.paymentStatus);
    final phase = status.phase;

    IconData statusIcon;
    Color statusColor;
    switch (phase) {
      case CheckoutPaymentPhase.pending:
        statusIcon = Icons.hourglass_top_rounded;
        statusColor = AppColors.brandBlue;
      case CheckoutPaymentPhase.success:
        statusIcon = Icons.check_circle;
        statusColor = AppColors.success;
      case CheckoutPaymentPhase.failed:
        statusIcon = Icons.error_outline;
        statusColor = AppColors.error;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s24,
      ),
      children: [
        PickupDashboardCard(
          child: Column(
            children: [
              Icon(statusIcon, color: statusColor, size: 56),
              const SizedBox(height: AppSpacing.s12),
              Text(
                status.displayLabel,
                textAlign: TextAlign.center,
                style: _poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                status.detailMessage,
                textAlign: TextAlign.center,
                style: _poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s16),
              _summaryRow('Nomor Order', order.orderNumber),
              const SizedBox(height: AppSpacing.s8),
              _summaryRow('Total', _currency.format(order.grandTotal), isTotal: true),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        if (phase == CheckoutPaymentPhase.pending)
          _primaryButton(
            label: 'Cek Status Pembayaran',
            onPressed: _checkPaymentStatus,
            loading: _checkingPayment,
          ),
        if (phase == CheckoutPaymentPhase.failed)
          _primaryButton(
            label: 'Ulangi Pembayaran',
            onPressed: () => setState(() => _step = _OrderPaymentStep.payment),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader('Memuat detail pembayaran...'),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brandBlue),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null || _order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader('Pembayaran pesanan'),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  child: Text(
                    _error ?? 'Pesanan tidak ditemukan',
                    textAlign: TextAlign.center,
                    style: _poppins(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final subtitle = switch (_step) {
      _OrderPaymentStep.payment => 'Pilih metode pembayaran',
      _OrderPaymentStep.paymentDetail => 'Detail pembayaran',
      _OrderPaymentStep.confirm => 'Konfirmasi pembayaran',
      _OrderPaymentStep.status => 'Status pembayaran pesanan',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(subtitle),
          Expanded(
            child: switch (_step) {
              _OrderPaymentStep.payment => _buildPaymentStep(),
              _OrderPaymentStep.paymentDetail => _buildPaymentDetailStep(),
              _OrderPaymentStep.confirm => _buildConfirmStep(),
              _OrderPaymentStep.status => _buildStatusStep(),
            },
          ),
        ],
      ),
    );
  }
}
