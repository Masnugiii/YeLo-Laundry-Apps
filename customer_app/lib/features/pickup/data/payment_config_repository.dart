import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/features/pickup/models/customer_payment_config.dart';

class PaymentConfigRepository {
  PaymentConfigRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  static const _paymentConfigEndpoint = '/customer-app/payment-config';

  Future<CustomerPaymentConfig> fetchPaymentConfig() async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.paymentConfig;
    }

    try {
      final data = await _api.get<Map<String, dynamic>>(
        _paymentConfigEndpoint,
        parser: (json) => json as Map<String, dynamic>,
      );
      return CustomerPaymentConfig.fromJson(data);
    } catch (_) {
      return CustomerPaymentConfig.empty;
    }
  }
}
