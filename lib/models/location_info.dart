// lib/models/location_info.dart
class LocationInfo {
  final double latitude;
  final double longitude;
  final String displayName;
  final bool isCurrentLocation;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.isCurrentLocation = false,
  });
}
