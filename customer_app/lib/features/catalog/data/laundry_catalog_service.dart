enum LaundryServiceUnit {
  perKg,
  perItem,
}

class LaundryCatalogService {
  const LaundryCatalogService({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.unit,
    this.description,
  });

  final String id;
  final String name;
  final int unitPrice;
  final LaundryServiceUnit unit;
  final String? description;

  String get unitSuffix => switch (unit) {
        LaundryServiceUnit.perKg => '/ kg',
        LaundryServiceUnit.perItem => '/ pcs',
      };

  String get priceLabel => 'Rp ${_format(unitPrice)} $unitSuffix';

  int lineTotal(int quantity) => unitPrice * quantity;

  static String _format(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}
