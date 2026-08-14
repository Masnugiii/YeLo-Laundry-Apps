import 'package:yelo_laundry_erp/features/new_order/models/laundry_service.dart';
import 'package:yelo_laundry_erp/features/new_order/models/selected_service_form.dart';
import 'package:yelo_laundry_erp/features/points/models/yelo_rewards_models.dart';

class SelectedOrderService {
  SelectedOrderService({
    required LaundryService service,
    this.quantity = 1,
    SelectedServiceForm? form,
  }) : form = form ?? SelectedServiceForm(service: service);

  double quantity;
  SelectedServiceForm form;

  LaundryService get service => form.service;

  int subtotalWithEntitlement(CksEntitlement? entitlement) {
    if (entitlement == null || !service.isCks) {
      return (service.unitPrice * quantity).round();
    }
    final freeKg = quantity < entitlement.remainingKg
        ? quantity
        : entitlement.remainingKg;
    final billableKg = quantity - freeKg;
    return (service.unitPrice * billableKg).round();
  }

  int get subtotal => (service.unitPrice * quantity).round();

  String get quantityLabel => service.unit == ServiceUnit.perKg
      ? '${quantity % 1 == 0 ? quantity.toInt() : quantity} Kg'
      : '${quantity.toInt()}';
}
