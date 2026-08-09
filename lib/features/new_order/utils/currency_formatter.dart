String formatRupiah(int amount) {
  final isNegative = amount < 0;
  final text = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(text[i]);
  }
  return '${isNegative ? '-' : ''}Rp$buffer';
}
