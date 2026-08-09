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
import 'package:yelo_laundry_erp/features/new_order/models/new_order_payment_method.dart';
import 'package:yelo_laundry_erp/features/new_order/models/selected_order_service.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/customer_section.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/new_order_bottom_actions.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/new_order_section_card.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/order_summary_section.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/selected_service_form_card.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/service_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/orders/providers/incoming_order_provider.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  Customer? _selectedCustomer;
  final List<SelectedOrderService> _selectedServices = [];
  NewOrderPaymentMethod _paymentMethod = NewOrderPaymentMethod.cash;
  bool _showWhatsAppShare = false;
  bool _isSaving = false;

  static const _dummyDiscount = 0;
  static const _dummyTax = 5000;

  int get _subtotal =>
      _selectedServices.fold(0, (sum, item) => sum + item.subtotal);

  int get _grandTotal => _subtotal - _dummyDiscount + _dummyTax;

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

  Future<void> _saveOrder() async {
    if (_isSaving) return;

    if (_selectedCustomer == null) {
      _showSnackBar('Pilih pelanggan terlebih dahulu.', isError: true);
      return;
    }

    if (_selectedServices.isEmpty) {
      _showSnackBar('Tambahkan minimal satu layanan.', isError: true);
      return;
    }

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
        return;
      }

      items.add({
        'serviceId': form.service.id,
        'quantity': quantity,
        if (form.service.unit == ServiceUnit.perKg && form.parsedWeightKg != null)
          'weight': form.parsedWeightKg,
      });
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(orderRepositoryProvider).createOrder({
        'customerId': _selectedCustomer!.id,
        'estimatedFinishDate':
            DateTime.now().add(const Duration(days: 2)).toUtc().toIso8601String(),
        'items': items,
        'taxAmount': _dummyTax,
      });

      ref.invalidate(incomingOrderProvider);

      if (!mounted) return;

      _showSnackBar('Order berhasil disimpan.');
      ref
          .read(dashboardShellTabProvider.notifier)
          .setTab(incomingOrdersDashboardTabIndex);
      context.go(ref.read(sessionProvider).role.dashboardRoute);
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
                      setState(() => _selectedCustomer = customer);
                    },
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
                              subtotal: _selectedServices[i].subtotal,
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
                    child: Row(
                      children: [
                        for (var i = 0;
                            i < NewOrderPaymentMethod.values.length;
                            i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(
                            child: SelectableChip(
                              expand: true,
                              label: NewOrderPaymentMethod.values[i].label,
                              isSelected: _paymentMethod ==
                                  NewOrderPaymentMethod.values[i],
                              onTap: () {
                                setState(() {
                                  _paymentMethod =
                                      NewOrderPaymentMethod.values[i];
                                });
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  OrderSummarySection(
                    subtotal: _subtotal,
                    discount: _dummyDiscount,
                    tax: _dummyTax,
                    grandTotal: _grandTotal,
                  ),
                ],
              ),
            ),
          ),
          NewOrderBottomActions(
            showWhatsAppShare: _showWhatsAppShare,
            onSaveOrder: _isSaving ? () {} : _saveOrder,
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
