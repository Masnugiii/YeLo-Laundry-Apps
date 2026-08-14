import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/features/catalog/data/laundry_catalog_service.dart';
import 'package:yelo_laundry_customer/features/catalog/data/laundry_perfume_option.dart';

class CatalogRepository {
  CatalogRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  /// Future endpoint: GET /customer-app/perfumes
  static const _perfumeEndpoint = '/customer-app/perfumes';

  Future<List<LaundryCatalogService>> fetchActiveServices() async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.catalogServices;
    }

    final data = await _api.get<List<dynamic>>(
      '/customer-app/services',
      parser: (json) => json as List<dynamic>,
    );

    return data
        .map((item) => _mapService(item as Map<String, dynamic>))
        .where((service) => service.unitPrice > 0)
        .toList();
  }

  Future<List<LaundryPerfumeOption>> fetchPerfumeOptions() async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.perfumeOptions;
    }

    try {
      final data = await _api.get<List<dynamic>>(
        _perfumeEndpoint,
        parser: (json) => json as List<dynamic>,
      );

      final options = data
          .map(
            (item) =>
                LaundryPerfumeOption.fromJson(item as Map<String, dynamic>),
          )
          .where((option) => option.name.isNotEmpty)
          .toList();

      return _withDefaultOption(options);
    } catch (_) {
      // Backend master data not available yet — only default option.
      return const [LaundryPerfumeOption.none];
    }
  }

  List<LaundryPerfumeOption> _withDefaultOption(
    List<LaundryPerfumeOption> options,
  ) {
    final withoutNone =
        options.where((option) => !option.isNone).toList(growable: false);
    return [LaundryPerfumeOption.none, ...withoutNone];
  }

  LaundryCatalogService _mapService(Map<String, dynamic> json) {
    final prices = json['prices'] as List<dynamic>? ?? const [];
    final activePrice = prices.isNotEmpty
        ? prices.first as Map<String, dynamic>
        : null;
    final rawPrice = activePrice?['price'];
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

    return LaundryCatalogService(
      id: json['id'] as String,
      name: json['serviceName'] as String? ?? '',
      unitPrice: unitPrice,
      unit: isWeightBased
          ? LaundryServiceUnit.perKg
          : LaundryServiceUnit.perItem,
      description: json['description'] as String?,
    );
  }
}
