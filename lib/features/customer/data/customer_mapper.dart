import 'package:yelo_laundry_erp/features/customer/models/customer.dart';

String? resolveCustomerAddress(Map<String, dynamic> json) {
  final defaultAddress = json['defaultAddress'];
  if (defaultAddress is Map<String, dynamic>) {
    final addressDetail = defaultAddress['addressDetail'];
    if (addressDetail is String && addressDetail.trim().isNotEmpty) {
      return addressDetail;
    }
  } else if (defaultAddress is String && defaultAddress.trim().isNotEmpty) {
    return defaultAddress;
  }

  final addressDetail = json['addressDetail'];
  if (addressDetail is String && addressDetail.trim().isNotEmpty) {
    return addressDetail;
  }

  return null;
}

Customer mapCustomerFromJson(Map<String, dynamic> json) {
  return Customer(
    id: json['id'] as String,
    name: json['fullName'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    occupation: json['occupation'] as String?,
    address: resolveCustomerAddress(json),
    walletBalance: (json['walletBalance'] as num?)?.toInt() ?? 0,
    points: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
    isMember: json['isMember'] as bool? ??
        (json['memberStatus'] as String?)?.toUpperCase() == 'MEMBER',
  );
}
