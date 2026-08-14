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
    this.code,
    this.description,
  });

  final String id;
  final String name;
  final int unitPrice;
  final ServiceUnit unit;
  final String? code;
  final String? description;

  bool get isCks {
    final normalized = (code ?? '').toUpperCase();
    if (normalized == 'CKS') return true;
    return name.toLowerCase().contains('cuci kering setrika') ||
        name.toUpperCase().contains('CKS');
  }

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
