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
import 'package:yelo_laundry_customer/features/catalog/data/laundry_catalog_service.dart';
import 'package:yelo_laundry_customer/features/catalog/data/laundry_perfume_option.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_address_input.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_method.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_status.dart';
import 'package:yelo_laundry_customer/features/pickup/models/customer_payment_config.dart';
import 'package:yelo_laundry_customer/features/pickup/models/laundry_checkout_draft.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/checkout_address_field.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/checkout_payment_detail_section.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/payment_method_selection_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/perfume_selection_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_service_item_card.dart';
import 'package:yelo_laundry_customer/features/promo/models/customer_promo_quote.dart';
import 'package:yelo_laundry_customer/features/promo/providers/promo_providers.dart';

enum _CheckoutStep {
  request,
  payment,
  paymentDetail,
  confirm,
  paymentStatus,
  success,
}

class PickupCheckoutFlowScreen extends ConsumerStatefulWidget {
  const PickupCheckoutFlowScreen({super.key});

  @override
  ConsumerState<PickupCheckoutFlowScreen> createState() =>
      _PickupCheckoutFlowScreenState();
}

class _PickupCheckoutFlowScreenState
    extends ConsumerState<PickupCheckoutFlowScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _dateFormat = DateFormat('d MMM yyyy, HH:mm');

  _CheckoutStep _step = _CheckoutStep.request;
  List<LaundryCatalogService> _services = [];
  List<LaundryPerfumeOption> _perfumeOptions = const [LaundryPerfumeOption.none];
  String _selectedPerfumeId = LaundryPerfumeOption.none.id;
  final Map<String, int> _quantities = {};
  CheckoutAddressInput _pickup = const CheckoutAddressInput();
  CheckoutAddressInput _delivery = const CheckoutAddressInput();
  final _notesController = TextEditingController();
  DateTime? _scheduledAt;
  String _paymentMethodCode = CheckoutPaymentMethods.yeloWallet;
  double? _walletBalance;
  CustomerPaymentConfig _paymentConfig = CustomerPaymentConfig.empty;
  LaundryCheckoutResult? _result;
  bool _loading = true;
  bool _submitting = false;
  bool _checkingPayment = false;
  String? _loadError;
  CustomerPromoQuote? _promoQuote;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
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

  int _quantityFor(String serviceId) => _quantities[serviceId] ?? 0;

  LaundryPerfumeOption get _selectedPerfume {
    for (final option in _perfumeOptions) {
      if (option.id == _selectedPerfumeId) return option;
    }
    return LaundryPerfumeOption.none;
  }

  Future<void> _refreshPromoQuote() async {
    final selectedPromo = ref.read(selectedPromoProvider);
    if (selectedPromo == null) {
      if (mounted) setState(() => _promoQuote = null);
      return;
    }

    try {
      final quote = await ref.read(promoRepositoryProvider).quotePromo(
            promoId: selectedPromo.id,
            subtotal: _draft.grandTotal.toDouble(),
          );
      if (mounted) setState(() => _promoQuote = quote);
    } catch (_) {
      if (mounted) setState(() => _promoQuote = null);
    }
  }

  Future<void> _goToConfirmStep() async {
    setState(() => _step = _CheckoutStep.confirm);
    await _refreshPromoQuote();
  }

  LaundryCheckoutDraft get _draft => LaundryCheckoutDraft(
        services: _services,
        quantities: _quantities,
        pickup: _pickup,
        delivery: _delivery,
        selectedPerfume: _selectedPerfume,
        notes: _notesController.text.trim(),
        scheduledAt: _scheduledAt,
        paymentMethodCode: _paymentMethodCode,
        walletBalance: _walletBalance,
      );

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final customerId = ref.read(sessionProvider).id;
      final services =
          await ref.read(catalogRepositoryProvider).fetchActiveServices();
      final perfumes =
          await ref.read(catalogRepositoryProvider).fetchPerfumeOptions();
      final wallet =
          await ref.read(walletRepositoryProvider).getWallet(customerId);
      final paymentConfig =
          await ref.read(paymentConfigRepositoryProvider).fetchPaymentConfig();

      if (!mounted) return;
      setState(() {
        _services = services;
        _perfumeOptions = perfumes;
        _selectedPerfumeId = LaundryPerfumeOption.none.id;
        _walletBalance = wallet.balance;
        _paymentConfig = paymentConfig;
        final available = paymentConfig.availableMethodCodes;
        if (available.isNotEmpty &&
            !available.contains(_paymentMethodCode)) {
          _paymentMethodCode = available.first;
        }
        for (final service in services) {
          _quantities.putIfAbsent(service.id, () => 0);
        }
      });
    } catch (error) {
      if (mounted) setState(() => _loadError = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _walletInsufficient =>
      _paymentMethodCode == CheckoutPaymentMethods.yeloWallet &&
      (_walletBalance ?? 0) < _draft.grandTotal;

  bool get _canContinueToConfirm => !_walletInsufficient;

  bool get _canContinueFromPayment {
    if (!_canContinueToConfirm) return false;
    if (_paymentMethodCode == CheckoutPaymentMethods.qris ||
        _paymentMethodCode == CheckoutPaymentMethods.bankTransfer) {
      return isPaymentDetailReady(_paymentMethodCode, _paymentConfig);
    }
    return true;
  }

  void _continueFromPayment() {
    if (!_canContinueToConfirm) return;
    if (_paymentMethodCode == CheckoutPaymentMethods.qris ||
        _paymentMethodCode == CheckoutPaymentMethods.bankTransfer) {
      setState(() => _step = _CheckoutStep.paymentDetail);
      return;
    }
    unawaited(_goToConfirmStep());
  }

  void _incrementService(String serviceId) {
    setState(() => _quantities[serviceId] = _quantityFor(serviceId) + 1);
  }

  void _decrementService(String serviceId) {
    final current = _quantityFor(serviceId);
    if (current <= 0) return;
    setState(() => _quantities[serviceId] = current - 1);
  }

  Future<void> _pickSchedule() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _handleBack() {
    if (_step == _CheckoutStep.success) {
      context.go('/laundry-status');
      return;
    }
    if (_step == _CheckoutStep.paymentStatus) {
      if (_result?.paymentStatus.phase == CheckoutPaymentPhase.failed) {
        setState(() => _step = _CheckoutStep.payment);
        return;
      }
      setState(() => _step = _CheckoutStep.confirm);
      return;
    }
    if (_step == _CheckoutStep.confirm) {
      if (_paymentMethodCode == CheckoutPaymentMethods.qris ||
          _paymentMethodCode == CheckoutPaymentMethods.bankTransfer) {
        setState(() => _step = _CheckoutStep.paymentDetail);
      } else {
        setState(() => _step = _CheckoutStep.payment);
      }
      return;
    }
    if (_step == _CheckoutStep.paymentDetail) {
      setState(() => _step = _CheckoutStep.payment);
      return;
    }
    if (_step == _CheckoutStep.payment) {
      setState(() => _step = _CheckoutStep.request);
      return;
    }
    context.go('/home');
  }

  Future<void> _submitCheckout() async {
    setState(() => _submitting = true);
    try {
      final result =
          await ref.read(laundryCheckoutRepositoryProvider).submit(_draft);
      if (!mounted) return;
      setState(() {
        _result = result;
        _step = _CheckoutStep.paymentStatus;
      });
    } on CheckoutApiException catch (error) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pesanan belum dapat diproses'),
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
    final result = _result;
    if (result == null) return;

    setState(() => _checkingPayment = true);
    try {
      final status = await ref
          .read(laundryCheckoutRepositoryProvider)
          .refreshPaymentStatus(result.orderId);
      if (!mounted) return;

      setState(() {
        _result = LaundryCheckoutResult(
          orderId: result.orderId,
          orderNumber: result.orderNumber,
          paymentStatus: status,
          grandTotal: result.grandTotal,
          pickup: result.pickup,
          delivery: result.delivery,
          selectedPerfume: result.selectedPerfume,
          lines: result.lines,
          paymentMethodLabel: result.paymentMethodLabel,
          usePickupDelivery: result.usePickupDelivery,
        );
      });

      if (status.phase == CheckoutPaymentPhase.success) {
        setState(() => _step = _CheckoutStep.success);
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

  void _retryPayment() {
    setState(() => _step = _CheckoutStep.payment);
  }

  void _continueToSuccess() {
    setState(() => _step = _CheckoutStep.success);
  }

  Widget _buildPaymentStatusStep() {
    final result = _result!;
    final status = result.paymentStatus;
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
                style: _poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              _summaryRow('Nomor Order', result.orderNumber),
              const SizedBox(height: AppSpacing.s8),
              _summaryRow('Status', status.rawStatus),
              const SizedBox(height: AppSpacing.s8),
              _summaryRow(
                'Total',
                _currency.format(result.grandTotal),
                isTotal: true,
              ),
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
        if (phase == CheckoutPaymentPhase.success)
          _primaryButton(
            label: 'Lanjut ke Pesanan Berhasil',
            onPressed: _continueToSuccess,
          ),
        if (phase == CheckoutPaymentPhase.failed)
          _primaryButton(
            label: 'Ulangi Pembayaran',
            onPressed: _retryPayment,
          ),
      ],
    );
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
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Pesan Laundry',
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        title,
        style: _poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
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
          disabledBackgroundColor:
              AppColors.accent.withValues(alpha: 0.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

  Widget _summaryCard(
    LaundryCheckoutDraft draft, {
    bool showPayment = false,
    CustomerPromoQuote? promoQuote,
  }) {
    return PickupDashboardCard(
      child: Column(
        children: [
          for (final line in draft.lines) ...[
            _summaryRow(
              '${line.service.name} x${line.quantity}',
              _currency.format(line.subtotal),
            ),
            const SizedBox(height: AppSpacing.s8),
          ],
          if (draft.lines.isEmpty)
            Text(
              'Belum ada jasa dipilih',
              style: _poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
          if (draft.lines.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.s12),
            _summaryRow('Biaya Laundry', _currency.format(draft.servicesSubtotal)),
            const SizedBox(height: AppSpacing.s8),
            _summaryRow('Parfum', draft.perfumeLabel),
            if (draft.selectedPerfume.hasExtraPrice) ...[
              const SizedBox(height: AppSpacing.s8),
              _summaryRow(
                'Biaya Parfum',
                _currency.format(draft.perfumeFee),
              ),
            ],
            const SizedBox(height: AppSpacing.s8),
            _summaryRow(
              'Antar Jemput',
              draft.deliveryFee == null
                  ? 'Belum dikonfigurasi'
                  : _currency.format(draft.deliveryFee!),
              valueColor: AppColors.textSecondary,
            ),
            if (promoQuote != null && promoQuote.discountAmount > 0) ...[
              const SizedBox(height: AppSpacing.s8),
              _summaryRow(
                'Diskon ${promoQuote.discountPercent ?? 0}%',
                '-${_currency.format(promoQuote.discountAmount)}',
                valueColor: AppColors.brandBlue,
              ),
            ],
            const SizedBox(height: AppSpacing.s12),
            _summaryRow(
              'Total',
              _currency.format(
                promoQuote?.total ?? draft.grandTotal,
              ),
              isTotal: true,
            ),
            if (showPayment) ...[
              const SizedBox(height: AppSpacing.s12),
              _summaryRow(
                'Metode Pembayaran',
                CheckoutPaymentMethods.label(draft.paymentMethodCode),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
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
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: _poppins(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ??
                  (isTotal ? AppColors.brandBlue : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addressReviewRow({
    required String title,
    required CheckoutAddressInput address,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: _poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text('📍', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.displayLabel,
                    style: _poppins(fontSize: 14),
                  ),
                  if (address.coordinatesLabel != null) ...[
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      address.coordinatesLabel!,
                      style: _poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestStep() {
    final draft = _draft;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s24,
      ),
      children: [
        _sectionTitle('Pilih Jasa Laundry'),
        if (_services.isEmpty)
          PickupDashboardCard(
            child: Text(
              'Belum ada jasa laundry aktif.',
              style: _poppins(fontSize: 14, color: AppColors.textSecondary),
            ),
          )
        else
          for (final service in _services) ...[
            PickupServiceItemCard(
              name: service.name,
              priceLabel: service.priceLabel,
              quantity: _quantityFor(service.id),
              onIncrement: () => _incrementService(service.id),
              onDecrement: () => _decrementService(service.id),
            ),
            const SizedBox(height: AppSpacing.s12),
          ],
        const SizedBox(height: AppSpacing.s4),
        PerfumeSelectionCard(
          options: _perfumeOptions,
          selectedId: _selectedPerfumeId,
          onSelected: (value) => setState(() => _selectedPerfumeId = value),
        ),
        const SizedBox(height: AppSpacing.s12),
        _sectionTitle('Permintaan Antar Jemput'),
        PickupDashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.brandBlue,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      'Antar Jemput Laundry',
                      style: _poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'Gunakan jasa antar jemput?',
                style: _poppins(fontSize: 14, color: AppColors.textSecondary),
              ),
              Text(
                'Ya — pickup & delivery',
                style: _poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        _sectionTitle('Alamat Pickup & Delivery'),
        CheckoutAddressField(
          title: 'Alamat Pickup',
          mapPickerTitle: 'Pilih Alamat Pickup',
          value: _pickup,
          onChanged: (value) => setState(() => _pickup = value),
        ),
        const SizedBox(height: AppSpacing.s12),
        CheckoutAddressField(
          title: 'Alamat Delivery',
          mapPickerTitle: 'Pilih Alamat Delivery',
          value: _delivery,
          onChanged: (value) => setState(() => _delivery = value),
        ),
        _sectionTitle('Jadwal & Catatan'),
        PickupDashboardCard(
          child: Column(
            children: [
              InkWell(
                onTap: _pickSchedule,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.brandBlue,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        'Jadwal Pickup',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _scheduledAt == null
                            ? 'Pilih waktu Pick-up'
                            : _dateFormat.format(_scheduledAt!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: _poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: _poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  labelStyle:
                      _poppins(fontSize: 13, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        _summaryCard(draft),
        const SizedBox(height: AppSpacing.s16),
        _primaryButton(
          label: 'Lanjutkan ke Pembayaran',
          onPressed: draft.isValidForPayment
              ? () => setState(() => _step = _CheckoutStep.payment)
              : null,
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    final draft = _draft;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s24,
      ),
      children: [
        _sectionTitle('Pembayaran'),
        _summaryCard(draft),
        const SizedBox(height: AppSpacing.s12),
        PaymentMethodSelectionCard(
          selectedCode: _paymentMethodCode,
          onSelected: (code) => setState(() => _paymentMethodCode = code),
          paymentConfig: _paymentConfig,
          walletBalance: _walletBalance,
          orderTotal: draft.grandTotal,
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
    final draft = _draft;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s24,
      ),
      children: [
        _sectionTitle('Detail Pembayaran'),
        CheckoutPaymentDetailSection(
          paymentMethodCode: _paymentMethodCode,
          totalAmount: draft.grandTotal,
          paymentConfig: _paymentConfig,
        ),
        const SizedBox(height: AppSpacing.s16),
        _primaryButton(
          label: 'Lanjutkan ke Konfirmasi',
          onPressed: isPaymentDetailReady(_paymentMethodCode, _paymentConfig)
              ? () => unawaited(_goToConfirmStep())
              : null,
        ),
      ],
    );
  }

  Widget _buildConfirmStep() {
    final draft = _draft;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s24,
      ),
      children: [
        _sectionTitle('Konfirmasi Pembayaran'),
        _summaryCard(draft, showPayment: true, promoQuote: _promoQuote),
        if (_paymentMethodCode == CheckoutPaymentMethods.qris ||
            _paymentMethodCode == CheckoutPaymentMethods.bankTransfer) ...[
          const SizedBox(height: AppSpacing.s12),
          CheckoutPaymentDetailSection(
            paymentMethodCode: _paymentMethodCode,
            totalAmount: draft.grandTotal,
            paymentConfig: _paymentConfig,
          ),
        ],
        const SizedBox(height: AppSpacing.s12),
        PickupDashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Antar Jemput',
                style: _poppins(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.s8),
              _addressReviewRow(title: 'Pickup', address: draft.pickup),
              const SizedBox(height: AppSpacing.s12),
              _addressReviewRow(title: 'Delivery', address: draft.delivery),
              if (draft.notes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s8),
                _summaryRow('Catatan', draft.notes),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        _primaryButton(
          label: 'Konfirmasi Pembayaran',
          onPressed: _submitCheckout,
          loading: _submitting,
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    final result = _result!;
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
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 56,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'Pesanan Berhasil',
                style: _poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              _summaryRow('Nomor Order', result.orderNumber),
              const SizedBox(height: AppSpacing.s8),
              _summaryRow('Status Pembayaran', result.paymentStatus.displayLabel),
              const SizedBox(height: AppSpacing.s8),
              for (final line in result.lines) ...[
                _summaryRow(
                  'Jasa Laundry',
                  '${line.service.name} x${line.quantity}',
                ),
                const SizedBox(height: AppSpacing.s4),
              ],
              const SizedBox(height: AppSpacing.s4),
              _summaryRow('Parfum', result.selectedPerfume.name),
              const SizedBox(height: AppSpacing.s8),
              _summaryRow(
                'Metode Pembayaran',
                result.paymentMethodLabel,
              ),
              const SizedBox(height: AppSpacing.s8),
              _summaryRow(
                'Antar Jemput',
                result.usePickupDelivery ? 'Ya' : 'Tidak',
              ),
              const SizedBox(height: AppSpacing.s8),
              _summaryRow(
                'Total Pembayaran',
                _currency.format(result.grandTotal),
                isTotal: true,
              ),
              const SizedBox(height: AppSpacing.s12),
              _addressReviewRow(title: 'Alamat Pickup', address: result.pickup),
              const SizedBox(height: AppSpacing.s12),
              _addressReviewRow(title: 'Alamat Delivery', address: result.delivery),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        _primaryButton(
          label: 'Lihat Status Laundry',
          onPressed: () => context.go('/laundry-status'),
        ),
      ],
    );
  }

  String get _headerSubtitle => switch (_step) {
        _CheckoutStep.request => 'Langkah 1 dari 3 — Permintaan antar jemput',
        _CheckoutStep.payment => 'Langkah 2 dari 3 — Pembayaran',
        _CheckoutStep.paymentDetail => 'Detail pembayaran',
        _CheckoutStep.confirm => 'Langkah 3 dari 3 — Konfirmasi pembayaran',
        _CheckoutStep.paymentStatus => 'Status pembayaran pesanan',
        _CheckoutStep.success => 'Pesanan berhasil dibuat',
      };

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader('Memuat data...'),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brandBlue),
              ),
            ),
          ],
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader('Gagal memuat'),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  child: Text(_loadError!, textAlign: TextAlign.center),
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
          _buildHeader(_headerSubtitle),
          Expanded(
            child: switch (_step) {
              _CheckoutStep.request => _buildRequestStep(),
              _CheckoutStep.payment => _buildPaymentStep(),
              _CheckoutStep.paymentDetail => _buildPaymentDetailStep(),
              _CheckoutStep.confirm => _buildConfirmStep(),
              _CheckoutStep.paymentStatus => _buildPaymentStatusStep(),
              _CheckoutStep.success => _buildSuccessStep(),
            },
          ),
        ],
      ),
    );
  }
}
