String formatPoints(int points) {
  final text = points.abs().toString();
  final buffer = StringBuffer();
  if (points < 0) {
    buffer.write('-');
  }
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(text[i]);
  }
  return buffer.toString();
}
