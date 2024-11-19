// lib/provider/location_provider.dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:find_your_pet/models/location_info.dart';

class LocationProvider extends ChangeNotifier {
  LocationInfo? _locationInfo;
  double _radius = 5.0;
  bool _isLoading = false;

  LocationInfo? get locationInfo => _locationInfo;
  double get radius => _radius;
  bool get isLoading => _isLoading;

  // Default location constants
  static const double _defaultLat = 37.7749; // Example: San Francisco latitude
  static const double _defaultLng =
      -122.4194; // Example: San Francisco longitude
  static const String _defaultDisplayName =
      'Default Location'; // Default location name

  // Initialize location
  Future<void> initCurrentLocation() async {
    try {
      _isLoading = true;
      notifyListeners();

      final hasPermission = await _checkLocationPermission();
      if (hasPermission) {
        final position = await Geolocator.getCurrentPosition();
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        String displayName = 'Current Location';
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          if (place.street?.isNotEmpty == true) {
            displayName = place.street!;
          } else if (place.locality?.isNotEmpty == true) {
            displayName = place.locality!;
          }
        }

        _locationInfo = LocationInfo(
          latitude: position.latitude,
          longitude: position.longitude,
          displayName: displayName,
          isCurrentLocation: true,
        );
      } else {
        // If permissions are denied, use default location
        _locationInfo = LocationInfo(
          latitude: _defaultLat,
          longitude: _defaultLng,
          displayName: _defaultDisplayName,
          isCurrentLocation: false,
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      // On error, use default location
      _locationInfo = LocationInfo(
        latitude: _defaultLat,
        longitude: _defaultLng,
        displayName: _defaultDisplayName,
        isCurrentLocation: false,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Update location and radius
  void updateLocation(LocationInfo location, double radius) {
    _locationInfo = location;
    _radius = radius;
    notifyListeners();
  }

  // Update radius
  void updateRadius(double radius) {
    _radius = radius;
    notifyListeners();
  }

  // Clear location
  void clearLocation() {
    _locationInfo = null;
    notifyListeners();
  }
}
