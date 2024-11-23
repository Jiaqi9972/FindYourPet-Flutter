import 'package:find_your_pet/models/map_location_info.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:find_your_pet/models/list_location_info.dart';

class LocationProvider extends ChangeNotifier {
  ListLocationInfo? _listLocationInfo;
  MapLocationInfo? _mapLocationInfo;
  bool _isLoading = false;
  String? _currentZipCode;

  static const double _defaultLat = 37.785834;
  static const double _defaultLng = -122.406417;
  static const String _defaultDisplayName = 'San Francisco, CA';
  static const String _defaultZipCode = '94103';

  ListLocationInfo? get listLocationInfo => _listLocationInfo;
  MapLocationInfo? get mapLocationInfo => _mapLocationInfo;
  bool get isLoading => _isLoading;
  String? get currentZipCode => _currentZipCode;

  String _formatDetailedAddress(Placemark place) {
    final List<String> addressComponents = [];

    // 添加街道地址
    if (place.thoroughfare?.isNotEmpty == true) {
      addressComponents.add(place.thoroughfare!);
    }

    // 添加区域/社区
    if (place.subLocality?.isNotEmpty == true) {
      addressComponents.add(place.subLocality!);
    }

    // 添加城市
    if (place.locality?.isNotEmpty == true) {
      addressComponents.add(place.locality!);
    }

    // 添加州/省
    if (place.administrativeArea?.isNotEmpty == true) {
      addressComponents.add(place.administrativeArea!);
    }

    // 添加邮编
    if (place.postalCode?.isNotEmpty == true) {
      addressComponents.add(place.postalCode!);
    }

    return addressComponents.isNotEmpty
        ? addressComponents.join(', ')
        : 'Unknown Location';
  }

  String _formatMapAddress(Placemark place) {
    final List<String> components = [];

    if (place.locality?.isNotEmpty == true) {
      components.add(place.locality!);
    }
    if (place.administrativeArea?.isNotEmpty == true) {
      components.add(place.administrativeArea!);
    }

    return components.isNotEmpty ? components.join(', ') : 'Unknown Location';
  }

  Future<void> initCurrentLocation() async {
    try {
      _isLoading = true;
      notifyListeners();

      final hasPermission = await _checkLocationPermission();
      if (hasPermission) {
        final position = await Geolocator.getCurrentPosition();

        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _currentZipCode = place.postalCode;

          _listLocationInfo = ListLocationInfo(
            latitude: position.latitude,
            longitude: position.longitude,
            displayName: _formatDetailedAddress(place),
            radius: 5.0,
          );

          _mapLocationInfo = MapLocationInfo(
            latitude: position.latitude,
            longitude: position.longitude,
            displayName: _formatMapAddress(place),
          );
        } else {
          _setDefaultLocations();
        }
      } else {
        _setDefaultLocations();
      }
    } catch (e) {
      print('Error getting location: $e');
      _setDefaultLocations();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setDefaultLocations() {
    _currentZipCode = _defaultZipCode;

    _listLocationInfo = ListLocationInfo(
      latitude: _defaultLat,
      longitude: _defaultLng,
      displayName: _defaultDisplayName,
      radius: 5.0,
    );

    _mapLocationInfo = MapLocationInfo(
      latitude: _defaultLat,
      longitude: _defaultLng,
      displayName: _defaultDisplayName,
    );
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    return permission != LocationPermission.deniedForever;
  }

  Future<void> updateMapLocationWithDetails(MapLocationInfo location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // 更新邮编
        _currentZipCode = place.postalCode;

        // 更新地图位置信息
        _mapLocationInfo = MapLocationInfo(
          latitude: location.latitude,
          longitude: location.longitude,
          displayName: _formatMapAddress(place),
          radiusInMiles: location.radiusInMiles,
        );
      } else {
        _mapLocationInfo = location;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating map location: $e');
      _mapLocationInfo = location;
      notifyListeners();
    }
  }

  Future<void> updateMapLocation(MapLocationInfo location) async {
    return updateMapLocationWithDetails(location);
  }

  Future<void> updateListLocation(ListLocationInfo location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // 更新邮编
        _currentZipCode = place.postalCode;

        // 更新位置信息
        _listLocationInfo = ListLocationInfo(
          latitude: location.latitude,
          longitude: location.longitude,
          displayName: _formatDetailedAddress(place),
          radius: location.radius,
        );

        // 同时更新地图位置信息以保持同步
        _mapLocationInfo = MapLocationInfo(
          latitude: location.latitude,
          longitude: location.longitude,
          displayName: _formatMapAddress(place),
        );
      } else {
        _listLocationInfo = location;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating list location: $e');
      _listLocationInfo = location;
      notifyListeners();
    }
  }

  void clearLocations() {
    _listLocationInfo = null;
    _mapLocationInfo = null;
    _currentZipCode = null;
    notifyListeners();
  }
}
