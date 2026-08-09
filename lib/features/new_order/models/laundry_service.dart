enum ServiceUnit {
  perKg,
  perItem,
}

class LaundryService {
  const LaundryService({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.unit,
    this.description,
  });

  final String id;
  final String name;
  final int unitPrice;
  final ServiceUnit unit;
  final String? description;

  String get unitLabel => switch (unit) {
        ServiceUnit.perKg => '/ Kg',
        ServiceUnit.perItem => '',
      };

  String get priceLabel => unit == ServiceUnit.perKg
      ? 'Rp${_format(unitPrice)} / Kg'
      : 'Rp${_format(unitPrice)}';

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
