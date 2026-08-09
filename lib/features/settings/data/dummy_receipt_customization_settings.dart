import 'package:yelo_laundry_erp/features/settings/models/receipt_customization_settings.dart';

ReceiptCustomizationSettings _receiptCustomizationSettings =
    const ReceiptCustomizationSettings();

ReceiptCustomizationSettings getReceiptCustomizationSettings() =>
    _receiptCustomizationSettings;

void saveReceiptCustomizationSettings(ReceiptCustomizationSettings settings) {
  _receiptCustomizationSettings = settings;
}

void resetReceiptCustomizationSettingsForTesting() {
  _receiptCustomizationSettings = const ReceiptCustomizationSettings();
}
