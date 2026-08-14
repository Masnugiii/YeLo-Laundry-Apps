import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';

class CustomerAddress {
  const CustomerAddress({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.addressDetail,
    required this.isDefault,
    this.postalCode,
    this.label,
    this.notes,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String recipientName;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String addressDetail;
  final bool isDefault;
  final String? postalCode;
  final String? label;
  final String? notes;
  final double? latitude;
  final double? longitude;

  String get fullAddress =>
      '$addressDetail, $district, $city, $province${postalCode != null ? ', $postalCode' : ''}';

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>?;
    return CustomerAddress(
      id: json['id'] as String,
      recipientName: json['recipientName'] as String,
      phone: json['phone'] as String,
      province: json['province'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      addressDetail: (json['addressDetail'] ?? json['address']) as String,
      isDefault: json['isDefault'] as bool? ?? false,
      postalCode: json['postalCode'] as String?,
      label: json['label'] as String?,
      notes: json['notes'] as String?,
      latitude: (coordinates?['latitude'] as num?)?.toDouble(),
      longitude: (coordinates?['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (label != null) 'label': label,
        'recipientName': recipientName,
        'phone': phone,
        'address': addressDetail,
        'province': province,
        'city': city,
        'district': district,
        if (postalCode != null) 'postalCode': postalCode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'isDefault': isDefault,
        if (notes != null) 'notes': notes,
      };
}

class AddressRepository {
  AddressRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<List<CustomerAddress>> list(String customerId) async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.addresses;
    }

    final data = await _api.get<List<dynamic>>(
      '/customers/$customerId/addresses',
      parser: (json) => json as List<dynamic>,
    );

    return data
        .map((item) => CustomerAddress.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerAddress> create(String customerId, CustomerAddress address) {
    return _save(customerId, address);
  }

  Future<CustomerAddress> update(
    String customerId,
    String addressId,
    CustomerAddress address,
  ) async {
    final data = await _api.patch<Map<String, dynamic>>(
      '/customers/$customerId/addresses/$addressId',
      data: address.toJson(),
      parser: (json) => json as Map<String, dynamic>,
    );
    return CustomerAddress.fromJson(data);
  }

  Future<CustomerAddress> _save(
    String customerId,
    CustomerAddress address,
  ) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/customers/$customerId/addresses',
      data: address.toJson(),
      parser: (json) => json as Map<String, dynamic>,
    );
    return CustomerAddress.fromJson(data);
  }

  Future<void> delete(String customerId, String addressId) async {
    await _api.delete<void>('/customers/$customerId/addresses/$addressId');
  }
}
