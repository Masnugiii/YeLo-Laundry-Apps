import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/data/dummy_laundry_services.dart';
import 'package:yelo_laundry_erp/features/new_order/models/laundry_service.dart';
import 'package:yelo_laundry_erp/features/new_order/models/selected_service_form.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/new_order_field_theme.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';

class SelectedServiceFormCard extends StatefulWidget {
  const SelectedServiceFormCard({
    super.key,
    required this.form,
    required this.subtotal,
    required this.onServiceChanged,
    required this.onWeightChanged,
    required this.onItemQuantityChanged,
    this.availableServices = dummyLaundryServices,
    this.showDivider = true,
  });

  final SelectedServiceForm form;
  final int subtotal;
  final ValueChanged<LaundryService> onServiceChanged;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onItemQuantityChanged;
  final List<LaundryService> availableServices;
  final bool showDivider;

  @override
  State<SelectedServiceFormCard> createState() => _SelectedServiceFormCardState();
}

class _SelectedServiceFormCardState extends State<SelectedServiceFormCard> {
  late final TextEditingController _weightController;
  late final TextEditingController _itemQuantityController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.form.weightKg);
    _itemQuantityController =
        TextEditingController(text: widget.form.itemQuantity);
  }

  @override
  void didUpdateWidget(covariant SelectedServiceFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.form.service.id != widget.form.service.id) {
      _weightController.text = widget.form.weightKg;
      _itemQuantityController.text = widget.form.itemQuantity;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _itemQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownServices = widget.availableServices
            .any((service) => service.id == widget.form.service.id)
        ? widget.availableServices
        : [widget.form.service, ...widget.availableServices];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showDivider) ...[
          const Divider(height: AppSpacing.s24, color: AppColors.divider),
        ],
        const _FieldLabel(label: 'Layanan'),
        const SizedBox(height: AppSpacing.s8),
        InputDecorator(
          decoration: NewOrderFieldTheme.decoration(hintText: 'Pilih layanan'),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<LaundryService>(
              isExpanded: true,
              value: widget.form.service,
              style: NewOrderFieldTheme.inputStyle,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
              items: [
                for (final service in dropdownServices)
                  DropdownMenuItem(
                    value: service,
                    child: Text(service.name),
                  ),
              ],
              onChanged: (service) {
                if (service != null) widget.onServiceChanged(service);
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        const _FieldLabel(label: 'Berat Laundry (Kg)'),
        const SizedBox(height: AppSpacing.s8),
        TextFormField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: NewOrderFieldTheme.inputStyle,
          decoration: NewOrderFieldTheme.decoration(
            hintText: 'Masukkan berat laundry',
            suffixText: 'Kg',
          ),
          onChanged: widget.onWeightChanged,
        ),
        const SizedBox(height: AppSpacing.s16),
        const _FieldLabel(label: 'Jumlah Item (Pcs)'),
        const SizedBox(height: AppSpacing.s8),
        TextFormField(
          controller: _itemQuantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: NewOrderFieldTheme.inputStyle,
          decoration: NewOrderFieldTheme.decoration(
            hintText: 'Masukkan jumlah pakaian',
            suffixText: 'Pcs',
          ),
          onChanged: widget.onItemQuantityChanged,
        ),
        const SizedBox(height: AppSpacing.s16),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            formatRupiah(widget.subtotal),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Subtotal',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class SelectedServiceHelperText extends StatelessWidget {
  const SelectedServiceHelperText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s16),
      child: Text(
        'Berat laundry digunakan untuk menghitung total biaya.\n\n'
        'Jumlah item digunakan sebagai informasi tambahan saat proses pencucian dan pengecekan.',
        style: NewOrderFieldTheme.helperStyle,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: NewOrderFieldTheme.labelStyle);
  }
}
