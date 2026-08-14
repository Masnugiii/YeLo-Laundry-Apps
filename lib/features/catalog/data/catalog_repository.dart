import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/features/new_order/models/laundry_service.dart';

class CatalogRepository {
  CatalogRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<LaundryService>> fetchActiveServices() async {
    final data = await _apiClient.get<List<dynamic>>(
      '/catalog/services',
      parser: (json) => json as List<dynamic>,
    );

    return data
        .where(
          (item) => (item as Map<String, dynamic>)['isActive'] as bool? ?? true,
        )
        .map((item) => _mapService(item as Map<String, dynamic>))
        .toList();
  }

  LaundryService _mapService(Map<String, dynamic> json) {
    final prices = json['prices'] as List<dynamic>? ?? const [];
    final firstPrice =
        prices.isNotEmpty ? prices.first as Map<String, dynamic> : null;
    final rawPrice = firstPrice?['price'];
    final unitPrice = switch (rawPrice) {
      num value => value.round(),
      String value => int.tryParse(value) ?? 0,
      _ => 0,
    };

    final isWeightBased = switch ((json['unitType'] as String?)?.toLowerCase()) {
      'piece' || 'item' => false,
      'kg' => true,
      _ => json['weight'] as bool? ?? true,
    };

    return LaundryService(
      id: json['id'] as String,
      name: json['serviceName'] as String? ?? '',
      code: json['serviceCode'] as String?,
      unitPrice: unitPrice,
      unit: isWeightBased ? ServiceUnit.perKg : ServiceUnit.perItem,
      description: json['description'] as String?,
    );
  }
}
