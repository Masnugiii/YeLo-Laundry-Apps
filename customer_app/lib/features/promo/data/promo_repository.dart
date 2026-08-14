import 'package:yelo_laundry_customer/core/config/app_config.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/features/promo/models/customer_promo.dart';
import 'package:yelo_laundry_customer/features/promo/models/customer_promo_quote.dart';

class PromoFetchResult {
  const PromoFetchResult({
    required this.promos,
    required this.apiAvailable,
  });

  final List<CustomerPromo> promos;
  final bool apiAvailable;
}

class PromoRepository {
  PromoRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  static const promosEndpoint = '/customer-app/promos';

  Future<PromoFetchResult> fetchActivePromos() async {
    if (DevPreviewGate.isActive) {
      return PromoFetchResult(
        promos: DevPreviewData.promos,
        apiAvailable: true,
      );
    }

    try {
      final data = await _api.get<Map<String, dynamic>>(
        promosEndpoint,
        queryParameters: {'limit': AppConfig.defaultPageSize},
        parser: (json) => json as Map<String, dynamic>,
      );

      final items = (data['items'] as List<dynamic>? ?? data['promos'] as List<dynamic>? ?? [])
          .map((item) => CustomerPromo.fromJson(item as Map<String, dynamic>))
          .where(_isPromoVisible)
          .toList();

      return PromoFetchResult(promos: items, apiAvailable: true);
    } on ApiException catch (error) {
      if (error.statusCode == 404 || error.statusCode == 501) {
        return const PromoFetchResult(promos: [], apiAvailable: false);
      }
      rethrow;
    }
  }

  bool _isPromoVisible(CustomerPromo promo) {
    if (promo.expiresAt != null && promo.expiresAt!.isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }

  Future<CustomerPromoQuote> quotePromo({
    required String promoId,
    required double subtotal,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '$promosEndpoint/quote',
      data: {
        'promoId': promoId,
        'subtotal': subtotal,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return CustomerPromoQuote.fromJson(data);
  }
}
