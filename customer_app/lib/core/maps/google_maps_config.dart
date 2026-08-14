class GoogleMapsConfig {
  GoogleMapsConfig._();

  static const String apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  /// Default map center: Probolinggo area (matches backend examples).
  static const double defaultLatitude = -7.756;
  static const double defaultLongitude = 113.215;

  static bool get isConfigured => apiKey.isNotEmpty;
}
