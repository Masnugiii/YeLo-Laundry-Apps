import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/features/promo/models/customer_promo.dart';

final selectedPromoProvider =
    NotifierProvider<SelectedPromoNotifier, CustomerPromo?>(
  SelectedPromoNotifier.new,
);

class SelectedPromoNotifier extends Notifier<CustomerPromo?> {
  @override
  CustomerPromo? build() => null;

  void select(CustomerPromo promo) => state = promo;

  void clear() => state = null;
}
