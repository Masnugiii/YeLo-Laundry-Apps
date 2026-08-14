/// Perfume option for laundry checkout.
///
/// When backend exposes perfume catalog (e.g. GET /customer-app/perfumes),
/// map API response into this model via [CatalogRepository.fetchPerfumeOptions].
class LaundryPerfumeOption {
  const LaundryPerfumeOption({
    required this.id,
    required this.name,
    this.extraPrice,
  });

  final String id;
  final String name;

  /// Additional charge in IDR. `null` or `0` means no extra cost.
  final int? extraPrice;

  static const none = LaundryPerfumeOption(
    id: 'none',
    name: 'Tanpa Parfum',
  );

  bool get isNone => id == none.id;

  bool get hasExtraPrice => extraPrice != null && extraPrice! > 0;

  String get priceLabel {
    if (!hasExtraPrice) return 'Gratis';
    return '+ Rp ${_formatPrice(extraPrice!)}';
  }

  String _formatPrice(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final position = raw.length - i;
      buffer.write(raw[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  factory LaundryPerfumeOption.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'] ?? json['extraPrice'] ?? json['amount'];
    final extraPrice = switch (rawPrice) {
      num value => value.round(),
      String value => int.tryParse(value),
      _ => null,
    };

    return LaundryPerfumeOption(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['perfumeName'] as String? ?? '',
      extraPrice: extraPrice,
    );
  }
}
