import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/core/membership/customer_yelo_points_provider.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_method.dart';
import 'package:yelo_laundry_customer/features/pickup/models/customer_payment_config.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/checkout_payment_detail_section.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/payment_method_selection_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';
import 'package:yelo_laundry_customer/features/wallet/data/wallet_repository.dart';

enum _TopUpStep { form, paymentDetail, waiting, success }

/// Preset amounts shown when backend does not expose top-up denomination config.
const _presetAmounts = [20000, 50000, 100000, 200000];

class WalletTopUpScreen extends ConsumerStatefulWidget {
  const WalletTopUpScreen({super.key});

  @override
  ConsumerState<WalletTopUpScreen> createState() => _WalletTopUpScreenState();
}

class _WalletTopUpScreenState extends ConsumerState<WalletTopUpScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  _TopUpStep _step = _TopUpStep.form;
  WalletSummary? _wallet;
  CustomerPaymentConfig _paymentConfig = CustomerPaymentConfig.empty;
  int? _selectedPreset;
  final _customAmountController = TextEditingController();
  String _paymentMethodCode = CheckoutPaymentMethods.qris;
  double _balanceBeforeTopUp = 0;
  int _pollCount = 0;
  Timer? _pollTimer;
  bool _loading = true;
  bool _submitting = false;
  bool _checkingPayment = false;
  String? _error;
  String? _topUpRequestId;

  int get _topUpAmount {
    if (_selectedPreset != null) return _selectedPreset!;
    final custom = int.tryParse(_customAmountController.text.replaceAll('.', ''));
    return custom ?? 0;
  }

  int get _feeAmount => 0;

  int get _totalAmount => _topUpAmount + _feeAmount;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _customAmountController.dispose();
    super.dispose();
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
      final customerId = ref.read(sessionProvider).id;
      final walletFuture = ref.read(walletRepositoryProvider).getWallet(customerId);
      final configFuture =
          ref.read(paymentConfigRepositoryProvider).fetchPaymentConfig();

      final results = await Future.wait([walletFuture, configFuture]);
      if (!mounted) return;

      final wallet = results[0] as WalletSummary;
      final config = results[1] as CustomerPaymentConfig;
      final methods = config.availableMethodCodes
          .where((code) => code != CheckoutPaymentMethods.yeloWallet)
          .toList();

      setState(() {
        _wallet = wallet;
        _paymentConfig = config;
        if (methods.isNotEmpty && !methods.contains(_paymentMethodCode)) {
          _paymentMethodCode = methods.first;
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshWalletBalance() async {
    final customerId = ref.read(sessionProvider).id;
    final wallet = await ref.read(walletRepositoryProvider).getWallet(customerId);
    if (mounted) setState(() => _wallet = wallet);
    return;
  }

  bool get _canSubmitTopUp {
    if (_topUpAmount <= 0) return false;
    if (_paymentMethodCode == CheckoutPaymentMethods.qris &&
        !_paymentConfig.qris.isConfigured) {
      return false;
    }
    if (_paymentMethodCode == CheckoutPaymentMethods.bankTransfer &&
        !_paymentConfig.bankTransfer.isConfigured) {
      return false;
    }
    return _paymentConfig.availableMethodCodes.contains(_paymentMethodCode);
  }

  Future<void> _startTopUp() async {
    if (!_canSubmitTopUp || _submitting) return;

    setState(() {
      _submitting = true;
      _balanceBeforeTopUp = _wallet?.balance ?? 0;
      _error = null;
    });

    try {
      final request = await ref.read(walletRepositoryProvider).initiateTopUp(
            amount: _topUpAmount.toDouble(),
            paymentMethod: _paymentMethodCode,
          );

      if (!mounted) return;
      setState(() {
        _topUpRequestId = request.requestId;
        _step = _TopUpStep.paymentDetail;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _confirmPayment() async {
    final requestId = _topUpRequestId;
    if (requestId == null) return;

    if (DevPreviewGate.isActive) {
      setState(() {
        _step = _TopUpStep.waiting;
        _checkingPayment = true;
        _pollCount = 0;
      });
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _pollPaymentStatusLegacy(),
      );
      await _pollPaymentStatusLegacy();
      return;
    }

    setState(() {
      _step = _TopUpStep.waiting;
      _checkingPayment = true;
      _pollCount = 0;
      _error = null;
    });

    try {
      await ref.read(walletRepositoryProvider).confirmTopUp(requestId);
      await _refreshWalletBalance();
      await refreshCustomerYeloPoints(ref);

      if (!mounted) return;
      setState(() {
        _checkingPayment = false;
        _step = _TopUpStep.success;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _checkingPayment = false;
        _error = error.toString();
        _step = _TopUpStep.paymentDetail;
      });
    }
  }

  Future<void> _pollPaymentStatusLegacy() async {
    if (!mounted || _step != _TopUpStep.waiting) return;

    _pollCount++;

    if (DevPreviewGate.isActive && _pollCount >= 2) {
      _pollTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _wallet = WalletSummary(
          balance: _balanceBeforeTopUp + _topUpAmount,
          currency: _wallet?.currency ?? 'IDR',
          totalTopup: (_wallet?.totalTopup ?? 0) + _topUpAmount,
          totalSpending: _wallet?.totalSpending ?? 0,
        );
        _checkingPayment = false;
        _step = _TopUpStep.success;
      });
      return;
    }

    try {
      await _refreshWalletBalance();
      final currentBalance = _wallet?.balance ?? 0;
      if (currentBalance >= _balanceBeforeTopUp + _topUpAmount) {
        _pollTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _checkingPayment = false;
          _step = _TopUpStep.success;
        });
      }
    } catch (_) {
      // Keep polling until backend confirms or user leaves.
    }
  }

  Widget _buildHeader({String? subtitle}) {
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
                    onPressed: () {
                      if (_step == _TopUpStep.form) {
                        context.pop();
                      } else if (_step == _TopUpStep.success) {
                        context.go('/home');
                      } else {
                        setState(() => _step = _TopUpStep.form);
                      }
                    },
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Top Up',
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
              if (subtitle != null) ...[
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: _poppins(
                fontSize: isTotal ? 14 : 13,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
                color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: _poppins(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? AppColors.brandBlue : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountChip(int amount) {
    final selected = _selectedPreset == amount;
    final accent = AppColors.accent;

    return InkWell(
      onTap: () => setState(() {
        _selectedPreset = amount;
        _customAmountController.clear();
      }),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.25) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accent : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          _currency.format(amount),
          style: _poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.brandBlue : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildFormStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      children: [
        PickupDashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yelo Wallet',
                style: _poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                _currency.format(_wallet?.balance ?? 0),
                style: _poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        PickupDashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Nominal Top Up',
                style: _poppins(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.s12),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: _presetAmounts
                    .map(
                      (amount) => SizedBox(
                        width: (MediaQuery.sizeOf(context).width -
                                AppSpacing.s16 * 2 -
                                AppSpacing.s16 * 2 -
                                AppSpacing.s8) /
                            2,
                        child: _amountChip(amount),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.s12),
              TextField(
                controller: _customAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() => _selectedPreset = null),
                decoration: InputDecoration(
                  labelText: 'Nominal lain',
                  hintText: 'Masukkan nominal',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        PaymentMethodSelectionCard(
          selectedCode: _paymentMethodCode,
          onSelected: (code) => setState(() => _paymentMethodCode = code),
          paymentConfig: _paymentConfig,
          allowedMethodCodes: const [
            CheckoutPaymentMethods.qris,
            CheckoutPaymentMethods.bankTransfer,
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        PickupDashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan',
                style: _poppins(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.s12),
              _summaryRow(
                'Nominal Top Up',
                _currency.format(_topUpAmount > 0 ? _topUpAmount : 0),
              ),
              _summaryRow('Biaya', _currency.format(_feeAmount)),
              _summaryRow(
                'Total',
                _currency.format(_totalAmount > 0 ? _totalAmount : 0),
                isTotal: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        _primaryButton(
          label: 'Top Up Sekarang',
          loading: _submitting,
          onPressed: _canSubmitTopUp ? _startTopUp : null,
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
        AppSpacing.s16,
      ),
      children: [
        CheckoutPaymentDetailSection(
          paymentMethodCode: _paymentMethodCode,
          totalAmount: _totalAmount,
          paymentConfig: _paymentConfig,
        ),
        const SizedBox(height: AppSpacing.s16),
        _primaryButton(
          label: 'Konfirmasi Pembayaran',
          onPressed: _confirmPayment,
        ),
      ],
    );
  }

  Widget _buildWaitingStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: PickupDashboardCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(color: AppColors.brandBlue),
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Menunggu Pembayaran',
                style: _poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Saldo akan bertambah setelah pembayaran dikonfirmasi.',
                textAlign: TextAlign.center,
                style: _poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
              if (_checkingPayment) ...[
                const SizedBox(height: AppSpacing.s16),
                OutlinedButton(
                  onPressed: _confirmPayment,
                  child: const Text('Cek Status Pembayaran'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      children: [
        PickupDashboardCard(
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 56),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'Top Up Berhasil',
                style: _poppins(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.s16),
              _summaryRow(
                'Nominal Top Up',
                _currency.format(_topUpAmount),
              ),
              _summaryRow(
                'Metode Pembayaran',
                CheckoutPaymentMethods.label(_paymentMethodCode),
              ),
              _summaryRow('Total', _currency.format(_totalAmount), isTotal: true),
              _summaryRow(
                'Saldo Terbaru',
                _currency.format(_wallet?.balance ?? 0),
                isTotal: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        _primaryButton(
          label: 'Kembali ke Dashboard',
          onPressed: () => context.go('/home'),
        ),
      ],
    );
  }

  String get _headerSubtitle => switch (_step) {
        _TopUpStep.form => 'Tambah saldo Yelo Wallet kamu',
        _TopUpStep.paymentDetail => 'Selesaikan pembayaran top up',
        _TopUpStep.waiting => 'Menunggu konfirmasi pembayaran',
        _TopUpStep.success => 'Saldo berhasil ditambahkan',
      };

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(subtitle: 'Memuat data...'),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brandBlue),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Gagal memuat data top up',
                        style: _poppins(fontSize: 18, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        _error!,
                        style: _poppins(fontSize: 14, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      FilledButton(
                        onPressed: _load,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandBlue,
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(subtitle: _headerSubtitle),
          Expanded(
            child: switch (_step) {
              _TopUpStep.form => _buildFormStep(),
              _TopUpStep.paymentDetail => _buildPaymentDetailStep(),
              _TopUpStep.waiting => _buildWaitingStep(),
              _TopUpStep.success => _buildSuccessStep(),
            },
          ),
        ],
      ),
    );
  }
}
