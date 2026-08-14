import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/network/api_exception.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/catalog/providers/catalog_provider.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_shell_tab_provider.dart';
import 'package:yelo_laundry_erp/features/new_order/models/laundry_service.dart';
import 'package:yelo_laundry_erp/features/new_order/models/new_order_payment_timing.dart';
import 'package:yelo_laundry_erp/features/new_order/models/selected_order_service.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/cks_benefit_section.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/customer_section.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/new_order_bottom_actions.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/new_order_section_card.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/order_summary_section.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/selected_service_form_card.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/service_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/providers/incoming_order_provider.dart';
import 'package:yelo_laundry_erp/features/orders/providers/order_query_providers.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/order_whatsapp_receipt_dialog.dart';
import 'package:yelo_laundry_erp/features/orders/utils/order_payment_flow_launcher.dart';
import 'package:yelo_laundry_erp/features/points/models/yelo_rewards_models.dart';
import 'package:yelo_laundry_erp/features/points/providers/yelo_rewards_provider.dart';
import 'package:yelo_laundry_erp/features/settings/models/system_settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/providers/settings_provider.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  Customer? _selectedCustomer;
  final List<SelectedOrderService> _selectedServices = [];
  NewOrderPaymentTiming _paymentTiming = NewOrderPaymentTiming.payNow;
  bool _showWhatsAppShare = false;
  bool _isSaving = false;
  String? _selectedEntitlementId;

  static const _defaultDiscount = 0;

  CksEntitlement? _selectedEntitlement(List<CksEntitlement> entitlements) {
    if (_selectedEntitlementId == null) return null;
    for (final item in entitlements) {
      if (item.redemptionItemId == _selectedEntitlementId) return item;
    }
    return null;
  }

  double get _cksOrderKg => _selectedServices
      .where((item) => item.service.isCks)
      .fold<double>(0, (sum, item) => sum + item.quantity);

  bool get _hasCksService =>
      _selectedServices.any((item) => item.service.isCks);

  double _freeKg(CksEntitlement? entitlement) {
    if (entitlement == null || !_hasCksService) return 0;
    final orderKg = _cksOrderKg;
    return orderKg < entitlement.remainingKg ? orderKg : entitlement.remainingKg;
  }

  double _billableKg(CksEntitlement? entitlement) {
    if (!_hasCksService) return 0;
    return _cksOrderKg - _freeKg(entitlement);
  }

  int _subtotal(CksEntitlement? entitlement) {
    var remainingFree = _freeKg(entitlement);
    var total = 0;
    for (final item in _selectedServices) {
      if (!item.service.isCks || entitlement == null) {
        total += item.subtotal;
        continue;
      }
      final freeForLine =
          item.quantity < remainingFree ? item.quantity : remainingFree;
      remainingFree -= freeForLine;
      final billable = item.quantity - freeForLine;
      total += (item.service.unitPrice * billable).round();
    }
    return total;
  }

  int _taxAmount(CompanySettings? settings, CksEntitlement? entitlement) {
    final rate = settings?.taxRate ?? 0;
    return ((_subtotal(entitlement) * rate) / 100).round();
  }

  int _grandTotal(CompanySettings? settings, CksEntitlement? entitlement) =>
      _subtotal(entitlement) - _defaultDiscount + _taxAmount(settings, entitlement);

  void _addService(LaundryService service) {
    final existing = _selectedServices
        .where((item) => item.service.id == service.id)
        .toList();

    setState(() {
      if (existing.isEmpty) {
        _selectedServices.add(SelectedOrderService(service: service));
      }
    });
  }

  void _updateService(
    SelectedOrderService item,
    LaundryService service,
  ) {
    setState(() {
      item.form = item.form.copyWith(service: service);
      if (!_hasCksService) {
        _selectedEntitlementId = null;
      }
    });
  }

  void _updateServiceFields(
    SelectedOrderService item, {
    String? weightKg,
    String? itemQuantity,
  }) {
    setState(() {
      if (weightKg != null) {
        item.form = item.form.copyWith(weightKg: weightKg);
        final parsed = item.form.parsedWeightKg;
        if (parsed != null) {
          item.quantity = parsed;
        }
      }
      if (itemQuantity != null) {
        item.form = item.form.copyWith(itemQuantity: itemQuantity);
        final parsed = item.form.parsedItemQuantity;
        if (parsed != null) {
          item.quantity = parsed.toDouble();
        }
      }
    });
  }

  List<Map<String, dynamic>>? _buildOrderItemsPayload() {
    final items = <Map<String, dynamic>>[];
    for (final selected in _selectedServices) {
      final form = selected.form;
      final quantity = form.service.unit == ServiceUnit.perKg
          ? form.parsedWeightKg
          : form.parsedItemQuantity?.toDouble();

      if (quantity == null || quantity <= 0) {
        _showSnackBar(
          'Lengkapi berat atau jumlah item untuk semua layanan.',
          isError: true,
        );
        return null;
      }

      items.add({
        'serviceId': form.service.id,
        'quantity': quantity,
        if (form.service.unit == ServiceUnit.perKg && form.parsedWeightKg != null)
          'weight': form.parsedWeightKg,
      });
    }
    return items;
  }

  Future<void> _continueOrder() async {
    if (_isSaving) return;

    if (_selectedCustomer == null) {
      _showSnackBar('Pilih pelanggan terlebih dahulu.', isError: true);
      return;
    }

    if (_selectedServices.isEmpty) {
      _showSnackBar('Tambahkan minimal satu layanan.', isError: true);
      return;
    }

    final items = _buildOrderItemsPayload();
    if (items == null) return;

    setState(() => _isSaving = true);

    try {
      final createdOrder = await ref.read(orderRepositoryProvider).createOrder({
        'customerId': _selectedCustomer!.id,
        'estimatedFinishDate':
            DateTime.now().add(const Duration(days: 2)).toUtc().toIso8601String(),
        'items': items,
        if (_selectedEntitlementId != null)
          'rewardRedemptionItemId': _selectedEntitlementId,
      });

      if (_selectedCustomer != null) {
        ref.invalidate(activeCksEntitlementsProvider(_selectedCustomer!.id));
        ref.invalidate(yeloRewardsSummaryProvider(_selectedCustomer!.id));
      }

      ref.invalidate(incomingOrderProvider);
      ref.invalidate(unpaidOrdersProvider);
      ref.invalidate(todayOrdersProvider);

      if (!mounted) return;

      if (_paymentTiming == NewOrderPaymentTiming.payLater) {
        await _handlePayLaterSuccess(createdOrder);
        return;
      }

      await _handlePayNowFlow(createdOrder);
    } on ApiException catch (error) {
      if (mounted) {
        _showSnackBar(error.message, isError: true);
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Gagal menyimpan order.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handlePayLaterSuccess(IncomingOrder order) async {
    final orderNumber = order.invoiceNumber.isNotEmpty
        ? order.invoiceNumber
        : order.queueNumber;

    final goToUnpaid = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Order Berhasil Dibuat',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Order $orderNumber untuk ${order.customerName} telah dibuat.\n\n'
          'Status pembayaran: UNPAID\n'
          'Total: Rp${_formatAmount(order.orderValue)}',
          style: GoogleFonts.poppins(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Kembali'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await showOrderWhatsappReceiptDialog(
                context,
                orderId: order.id,
                subtitle:
                    'Kirim bukti order dengan status BELUM DIBAYAR ke customer.',
              );
            },
            icon: const Icon(Icons.chat_outlined, size: 18),
            label: const Text('Kirim Struk via WhatsApp'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Lihat Belum Bayar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (goToUnpaid == true) {
      context.go('/unpaid-orders');
      return;
    }

    ref.read(dashboardShellTabProvider.notifier).setTab(incomingOrdersDashboardTabIndex);
    context.go(ref.read(sessionProvider).role.dashboardRoute);
  }

  Future<void> _handlePayNowFlow(IncomingOrder order) async {
    final confirmation = await launchOrderPaymentFlow(
      context,
      order: order,
    );

    if (!mounted) return;

    if (confirmation != null) {
      ref.invalidate(incomingOrderProvider);
      ref.invalidate(unpaidOrdersProvider);
      ref.invalidate(todayOrdersProvider);

      _showSnackBar('Pembayaran berhasil. Order ${confirmation.queueNumber} lunas.');
      ref.read(dashboardShellTabProvider.notifier).setTab(incomingOrdersDashboardTabIndex);
      context.go(ref.read(sessionProvider).role.dashboardRoute);
      return;
    }

    _showSnackBar(
      'Order ${order.invoiceNumber.isNotEmpty ? order.invoiceNumber : order.queueNumber} '
      'telah dibuat dengan status UNPAID.',
    );
    ref.read(dashboardShellTabProvider.notifier).setTab(incomingOrdersDashboardTabIndex);
    context.go(ref.read(sessionProvider).role.dashboardRoute);
  }

  String _formatAmount(int amount) {
    final value = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final position = value.length - i;
      buffer.write(value[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogProvider);
    final availableServices = catalogAsync.value ?? const <LaundryService>[];
    final companySettings = ref.watch(companySettingsProvider).value;
    final entitlementsAsync = _selectedCustomer == null
        ? const AsyncValue<List<CksEntitlement>>.data([])
        : ref.watch(activeCksEntitlementsProvider(_selectedCustomer!.id));
    final entitlements = entitlementsAsync.value ?? const <CksEntitlement>[];
    final selectedEntitlement = _selectedEntitlement(entitlements);
    final tax = _taxAmount(companySettings, selectedEntitlement);
    final grandTotal = _grandTotal(companySettings, selectedEntitlement);
    final subtotal = _subtotal(selectedEntitlement);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Order Baru',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomerSection(
                    selectedCustomer: _selectedCustomer,
                    onCustomerSelected: (customer) {
                      setState(() {
                        _selectedCustomer = customer;
                        _selectedEntitlementId = null;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  CksBenefitSection(
                    entitlements: entitlements,
                    selectedId: _selectedEntitlementId,
                    onSelected: (value) {
                      setState(() => _selectedEntitlementId = value);
                    },
                    freeKg: _freeKg(selectedEntitlement),
                    billableKg: _billableKg(selectedEntitlement),
                    hasCksService: _hasCksService,
                    isLoading: entitlementsAsync.isLoading,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  NewOrderSectionCard(
                    title: 'Layanan Laundry',
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                showServiceBottomSheet(
                                  context,
                                  onServiceSelected: _addService,
                                );
                              },
                        child: const Text('Tambahkan Layanan'),
                      ),
                    ),
                  ),
                  if (_selectedServices.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s16),
                    NewOrderSectionCard(
                      title: 'Layanan Dipilih',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < _selectedServices.length; i++)
                            SelectedServiceFormCard(
                              form: _selectedServices[i].form,
                              subtotal: _selectedServices[i]
                                  .subtotalWithEntitlement(selectedEntitlement),
                              showDivider: i > 0,
                              availableServices: availableServices,
                              onServiceChanged: (service) =>
                                  _updateService(_selectedServices[i], service),
                              onWeightChanged: (value) => _updateServiceFields(
                                _selectedServices[i],
                                weightKg: value,
                              ),
                              onItemQuantityChanged: (value) =>
                                  _updateServiceFields(
                                _selectedServices[i],
                                itemQuantity: value,
                              ),
                            ),
                          const SelectedServiceHelperText(),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  NewOrderSectionCard(
                    title: 'Pembayaran',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            for (var i = 0;
                                i < NewOrderPaymentTiming.values.length;
                                i++) ...[
                              if (i > 0) const SizedBox(width: 12),
                              Expanded(
                                child: SelectableChip(
                                  expand: true,
                                  label: NewOrderPaymentTiming.values[i].label,
                                  isSelected: _paymentTiming ==
                                      NewOrderPaymentTiming.values[i],
                                  onTap: _isSaving
                                      ? () {}
                                      : () {
                                          setState(() {
                                            _paymentTiming =
                                                NewOrderPaymentTiming.values[i];
                                          });
                                        },
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        Text(
                          _paymentTiming.description,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  OrderSummarySection(
                    subtotal: subtotal,
                    discount: _defaultDiscount,
                    tax: tax,
                    grandTotal: grandTotal,
                  ),
                ],
              ),
            ),
          ),
          NewOrderBottomActions(
            isLoading: _isSaving,
            showWhatsAppShare: _showWhatsAppShare,
            onContinueOrder: _isSaving ? () {} : _continueOrder,
            onPrintReceipt: () {
              setState(() => _showWhatsAppShare = true);
              context.push('/laundry-receipt');
            },
            onShareWhatsApp: () => context.push('/laundry-receipt'),
          ),
        ],
      ),
    );
  }
}
