import 'package:yelo_laundry_erp/features/new_order/models/laundry_service.dart';

/// UI-only form state for a selected laundry service on the New Order page.
class SelectedServiceForm {
  SelectedServiceForm({
    required this.service,
    this.weightKg = '',
    this.itemQuantity = '',
  });

  final LaundryService service;
  String weightKg;
  String itemQuantity;

  double? get parsedWeightKg => double.tryParse(weightKg.replaceAll(',', '.'));

  int? get parsedItemQuantity => int.tryParse(itemQuantity);

  SelectedServiceForm copyWith({
    LaundryService? service,
    String? weightKg,
    String? itemQuantity,
  }) {
    return SelectedServiceForm(
      service: service ?? this.service,
      weightKg: weightKg ?? this.weightKg,
      itemQuantity: itemQuantity ?? this.itemQuantity,
    );
  }
}
