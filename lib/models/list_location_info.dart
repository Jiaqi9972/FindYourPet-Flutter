class ListLocationInfo {
  final double latitude;
  final double longitude;
  final String displayName;
  final bool isCurrentLocation;
  final double radius;

  ListLocationInfo({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.isCurrentLocation = false,
    this.radius = 5.0,
  });
}
