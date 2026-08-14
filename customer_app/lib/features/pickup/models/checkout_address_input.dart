class CheckoutAddressInput {
  const CheckoutAddressInput({
    this.address = '',
    this.latitude,
    this.longitude,
  });

  final String address;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get isFilled => address.trim().isNotEmpty;

  String get displayLabel => address.trim().isEmpty ? '-' : address.trim();

  String? get coordinatesLabel {
    if (!hasCoordinates) return null;
    return '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}';
  }

  CheckoutAddressInput copyWith({
    String? address,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
  }) {
    return CheckoutAddressInput(
      address: address ?? this.address,
      latitude: clearCoordinates ? null : (latitude ?? this.latitude),
      longitude: clearCoordinates ? null : (longitude ?? this.longitude),
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}
