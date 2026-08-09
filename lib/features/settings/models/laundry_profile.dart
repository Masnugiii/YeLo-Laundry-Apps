class LaundryProfile {
  const LaundryProfile({
    required this.name,
    required this.address,
    required this.city,
    required this.whatsapp,
    required this.instagram,
    required this.website,
    this.logoAsset = 'assets/images/Logo_WithBackground.png',
  });

  final String name;
  final String address;
  final String city;
  final String whatsapp;
  final String instagram;
  final String website;
  final String logoAsset;

  String get fullAddress => '$address\n$city';

  LaundryProfile copyWith({
    String? name,
    String? address,
    String? city,
    String? whatsapp,
    String? instagram,
    String? website,
    String? logoAsset,
  }) {
    return LaundryProfile(
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      whatsapp: whatsapp ?? this.whatsapp,
      instagram: instagram ?? this.instagram,
      website: website ?? this.website,
      logoAsset: logoAsset ?? this.logoAsset,
    );
  }
}
