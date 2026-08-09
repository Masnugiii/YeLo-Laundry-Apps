import 'package:yelo_laundry_erp/features/settings/models/order_number_settings.dart';

OrderNumberSettings _orderNumberSettings = const OrderNumberSettings();

OrderNumberSettings getOrderNumberSettings() => _orderNumberSettings;

void saveOrderNumberSettings(String startingQueueNumber) {
  _orderNumberSettings = _orderNumberSettings.copyWith(
    startingQueueNumber: startingQueueNumber,
  );
}

void resetOrderNumberSettingsForTesting() {
  _orderNumberSettings = const OrderNumberSettings();
}
