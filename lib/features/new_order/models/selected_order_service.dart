import 'package:yelo_laundry_erp/features/new_order/models/laundry_service.dart';
import 'package:yelo_laundry_erp/features/new_order/models/selected_service_form.dart';

class SelectedOrderService {
  SelectedOrderService({
    required LaundryService service,
    this.quantity = 1,
    SelectedServiceForm? form,
  }) : form = form ?? SelectedServiceForm(service: service);

  double quantity;
  SelectedServiceForm form;

  LaundryService get service => form.service;

  int get subtotal => (service.unitPrice * quantity).round();

  String get quantityLabel => service.unit == ServiceUnit.perKg
      ? '${quantity % 1 == 0 ? quantity.toInt() : quantity} Kg'
      : '${quantity.toInt()}';
}
