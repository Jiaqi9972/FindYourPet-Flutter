import 'package:geocoding/geocoding.dart';

class MapLocationInfo {
  final double latitude;
  final double longitude;
  String displayName;
  final double radiusInMiles;

  MapLocationInfo({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.radiusInMiles = 5.0,
  });

  Future<void> updateDisplayName() async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        displayName = '${placemark.locality}, ${placemark.administrativeArea}';
      }
    } catch (e) {
      displayName = 'Unknown Location';
    }
  }
}
