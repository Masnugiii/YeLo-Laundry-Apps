import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/new_order/models/laundry_service.dart';
import 'package:yelo_laundry_erp/features/new_order/models/new_order_payment_method.dart';
import 'package:yelo_laundry_erp/features/new_order/models/selected_order_service.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/customer_section.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/new_order_bottom_actions.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/new_order_section_card.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/order_summary_section.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/selected_service_form_card.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/service_bottom_sheet.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  Customer? _selectedCustomer;
  final List<SelectedOrderService> _selectedServices = [];
  NewOrderPaymentMethod _paymentMethod = NewOrderPaymentMethod.cash;
  bool _showWhatsAppShare = false;

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
      }
      if (itemQuantity != null) {
        item.form = item.form.copyWith(itemQuantity: itemQuantity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        onPressed: () {
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
                        for (var i = 0; i < NewOrderPaymentMethod.values.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(
                            child: SelectableChip(
                              expand: true,
                              label: NewOrderPaymentMethod.values[i].label,
                              isSelected:
                                  _paymentMethod == NewOrderPaymentMethod.values[i],
                              onTap: () {
                                setState(() {
                                  _paymentMethod = NewOrderPaymentMethod.values[i];
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
            onSaveOrder: () {},
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
