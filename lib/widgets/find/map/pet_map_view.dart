import 'dart:math';
import 'package:find_your_pet/api/api_service.dart';
import 'package:find_your_pet/models/lost_pet.dart';
import 'package:find_your_pet/models/map_location_info.dart';
import 'package:find_your_pet/pages/find/pet_detail_page.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:find_your_pet/styles/color/app_colors_config.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class PetMapView extends StatefulWidget {
  final Map<String, dynamic> filters;
  final double initialLat;
  final double initialLng;

  const PetMapView({
    Key? key,
    required this.filters,
    required this.initialLat,
    required this.initialLng,
  }) : super(key: key);

  @override
  _PetMapViewState createState() => _PetMapViewState();
}

class _PetMapViewState extends State<PetMapView> {
  final ApiService _apiService = ApiService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _hasMarkers = false;
  bool _needsUpdate = false;

  late double _mapCenterLat;
  late double _mapCenterLng;

  @override
  void initState() {
    super.initState();
    _mapCenterLat = widget.initialLat;
    _mapCenterLng = widget.initialLng;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onCameraIdle() {
    if (_mapController == null || !mounted) return;

    _mapController!.getVisibleRegion().then((bounds) async {
      if (!mounted) return;

      double centerLat =
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
      double centerLng =
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
      double radiusInMiles = _calculateRadiusInMiles(bounds);

      if (_shouldUpdateLocation(centerLat, centerLng)) {
        _mapCenterLat = centerLat;
        _mapCenterLng = centerLng;

        try {
          List<Placemark> placemarks =
              await placemarkFromCoordinates(centerLat, centerLng);
          if (!mounted) return;

          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            context.read<LocationProvider>().updateMapLocation(
                  MapLocationInfo(
                    latitude: centerLat,
                    longitude: centerLng,
                    displayName: _formatAddress(placemark),
                    radiusInMiles: radiusInMiles,
                  ),
                );
          }
        } catch (e) {
          print('Error retrieving address: $e');
        }

        _needsUpdate = true;
        _fetchAndDisplayPets();
      }
    });
  }

  bool _shouldUpdateLocation(double newLat, double newLng) {
    const threshold = 0.01;
    return (_mapCenterLat - newLat).abs() > threshold ||
        (_mapCenterLng - newLng).abs() > threshold;
  }

  String _formatAddress(Placemark placemark) {
    final List<String> components = [];
    if (placemark.locality?.isNotEmpty ?? false)
      components.add(placemark.locality!);
    if (placemark.administrativeArea?.isNotEmpty ?? false)
      components.add(placemark.administrativeArea!);
    return components.join(", ");
  }

  Future<void> _fetchAndDisplayPets() async {
    if (!mounted || !_needsUpdate) return;
    _needsUpdate = false;

    try {
      final pets = await _apiService.fetchLostPetsForMap(
        _mapCenterLat,
        _mapCenterLng,
        widget.filters['radiusInMiles'] ?? 5.0,
        widget.filters['lost'],
      );

      if (!mounted) return;

      setState(() {
        _markers = pets.map(_createMarker).toSet();
        _hasMarkers = _markers.isNotEmpty;
      });
    } catch (e) {
      print('Error fetching pets: $e');
    }
  }

  @override
  void didUpdateWidget(PetMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialLat != widget.initialLat ||
        oldWidget.initialLng != widget.initialLng) {
      _mapCenterLat = widget.initialLat;
      _mapCenterLng = widget.initialLng;
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(_mapCenterLat, _mapCenterLng)),
      );
    }

    if (oldWidget.filters != widget.filters ||
        oldWidget.initialLat != widget.initialLat ||
        oldWidget.initialLng != widget.initialLng) {
      _needsUpdate = true;
      _fetchAndDisplayPets();
    }
  }

  Marker _createMarker(LostPet pet) {
    return Marker(
      markerId: MarkerId(pet.id),
      position: LatLng(pet.latitude, pet.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        pet.lost ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
      ),
      onTap: () => PetDetailPage.show(context, pet.id),
    );
  }

  double _calculateRadiusInMiles(LatLngBounds bounds) {
    final distanceInMeters = _distanceBetween(
      bounds.northeast.latitude,
      bounds.northeast.longitude,
      bounds.southwest.latitude,
      bounds.southwest.longitude,
    );
    return (distanceInMeters / 1609.34) / 2;
  }

  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Earth's radius in meters
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(_mapCenterLat, _mapCenterLng),
            zoom: 12,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            final isDarkMode = context.read<ThemeProvider>().isDarkMode;
            final colors = AppColorsConfig.getTheme(isDarkMode);
            controller.setMapStyle(colors.googleMapStyle);
            _needsUpdate = true;
            _fetchAndDisplayPets();
          },
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onCameraIdle: _onCameraIdle,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
        ),
        if (!_hasMarkers)
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No pets found in this area',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              FloatingActionButton(
                mini: true,
                heroTag: 'zoom_in',
                child: const Icon(CupertinoIcons.plus),
                onPressed: () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                },
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                heroTag: 'zoom_out',
                child: const Icon(CupertinoIcons.minus),
                onPressed: () {
                  _mapController?.animateCamera(CameraUpdate.zoomOut());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
