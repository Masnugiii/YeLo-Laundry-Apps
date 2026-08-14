import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService() : _geocoding = Geocoding();

  final Geocoding _geocoding;
  Future<({double latitude, double longitude})?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return (latitude: position.latitude, longitude: position.longitude);
  }

  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final placemarks = await _geocoding.placemarkFromCoordinates(
      latitude,
      longitude,
    );
    if (placemarks.isEmpty) return null;
    return _formatPlacemark(placemarks.first);
  }

  Future<({double latitude, double longitude})?> geocodeAddress(
    String query,
  ) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    final locations = await _geocoding.locationFromAddress(trimmed);
    if (locations.isEmpty) return null;

    final location = locations.first;
    return (latitude: location.latitude, longitude: location.longitude);
  }

  String _formatPlacemark(Placemark placemark) {
    final parts = <String>[
      if ((placemark.street ?? '').trim().isNotEmpty) placemark.street!.trim(),
      if ((placemark.subLocality ?? '').trim().isNotEmpty)
        placemark.subLocality!.trim(),
      if ((placemark.locality ?? '').trim().isNotEmpty)
        placemark.locality!.trim(),
      if ((placemark.subAdministrativeArea ?? '').trim().isNotEmpty)
        placemark.subAdministrativeArea!.trim(),
      if ((placemark.administrativeArea ?? '').trim().isNotEmpty)
        placemark.administrativeArea!.trim(),
      if ((placemark.postalCode ?? '').trim().isNotEmpty)
        placemark.postalCode!.trim(),
    ];

    final unique = <String>[];
    for (final part in parts) {
      if (!unique.contains(part)) unique.add(part);
    }

    return unique.join(', ');
  }
}
