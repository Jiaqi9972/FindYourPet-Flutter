// lib/widgets/main/pet_map_view.dart

import 'dart:math';

import 'package:find_your_pet/api/api_service.dart';
import 'package:find_your_pet/models/lost_pet.dart';
import 'package:find_your_pet/pages/main/pet_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';

class PetMapView extends StatefulWidget {
  final Map<String, dynamic> filters;
  // Removed the onMapPositionChanged callback since it's no longer needed
  // final Function(double, double) onMapPositionChanged;

  final double initialLat;
  final double initialLng;

  const PetMapView({
    Key? key,
    required this.filters,
    // required this.onMapPositionChanged,
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

  late double _mapCenterLat;
  late double _mapCenterLng;
  double _currentRadiusInMiles = 5.0;

  @override
  void initState() {
    super.initState();
    _mapCenterLat = widget.initialLat;
    _mapCenterLng = widget.initialLng;
  }

  @override
  void didUpdateWidget(PetMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filters['lost'] != oldWidget.filters['lost']) {
      _fetchAndDisplayPets();
    }

    // Only recenter the map if the initial coordinates changed significantly
    if (_coordinatesChangedDueToAddressInput(
      oldWidget.initialLat,
      widget.initialLat,
      oldWidget.initialLng,
      widget.initialLng,
    )) {
      _mapCenterLat = widget.initialLat;
      _mapCenterLng = widget.initialLng;
      _moveMapToCenter();
      _fetchAndDisplayPets();
    }
  }

  // Helper method to check if coordinates changed significantly
  bool _coordinatesChangedDueToAddressInput(
    double oldLat,
    double newLat,
    double oldLng,
    double newLng,
  ) {
    const threshold = 0.0001; // Adjust threshold as needed
    return (oldLat - newLat).abs() > threshold ||
        (oldLng - newLng).abs() > threshold;
  }

  void _moveMapToCenter() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_mapCenterLat, _mapCenterLng),
        ),
      );
    }
  }

  Future<void> _fetchAndDisplayPets() async {
    try {
      var pets = await _apiService.fetchLostPetsForMap(
        _mapCenterLat,
        _mapCenterLng,
        _currentRadiusInMiles,
        widget.filters['lost'],
      );

      if (!mounted) return;

      setState(() {
        _markers = pets.map((pet) => _createMarker(pet)).toSet();
      });
    } catch (e) {
      print('Error fetching pets for map: $e');
      _showError('Failed to load pets');
    }
  }

  Marker _createMarker(LostPet pet) {
    return Marker(
      markerId: MarkerId(pet.id),
      position: LatLng(pet.latitude, pet.longitude),
      infoWindow: InfoWindow(
        title: pet.name,
        snippet: pet.lost ? 'Lost' : 'Found',
        onTap: () => _openPetDetail(pet.id),
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        pet.lost ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    final theme = context.read<ThemeProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            'Error',
            style: TextStyle(color: theme.colors.destructive),
          ),
          content: Text(
            message,
            style: TextStyle(color: theme.colors.foreground),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: TextStyle(color: theme.colors.foreground),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    });
  }

  void _openPetDetail(String petId) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PetDetailPage(petId: petId),
      ),
    );
  }

  void _onCameraIdle() {
    if (_mapController == null) return;
    _mapController!.getVisibleRegion().then((bounds) {
      double centerLat =
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
      double centerLng =
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2;

      // Calculate radius in miles
      double radiusInMiles = _calculateRadiusInMiles(bounds);

      setState(() {
        _mapCenterLat = centerLat;
        _mapCenterLng = centerLng;
        _currentRadiusInMiles = radiusInMiles;
      });

      // Remove the call to widget.onMapPositionChanged
      // widget.onMapPositionChanged(centerLat, centerLng);

      _fetchAndDisplayPets(); // Fetch pets for the new map center
    });
  }

  double _calculateRadiusInMiles(LatLngBounds bounds) {
    final northeast = bounds.northeast;
    final southwest = bounds.southwest;

    // Calculate the diagonal distance between northeast and southwest corners
    final distanceInMeters = _distanceBetween(
      northeast.latitude,
      northeast.longitude,
      southwest.latitude,
      southwest.longitude,
    );

    // Convert meters to miles (1 mile = 1609.34 meters)
    final distanceInMiles = distanceInMeters / 1609.34;

    // Radius is half the diagonal distance
    return distanceInMiles / 2;
  }

  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Earth radius in meters
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

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final mapStyle = theme.getGoogleMapStyle();

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(_mapCenterLat, _mapCenterLng),
            zoom: 12,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            _mapController?.setMapStyle(mapStyle);
            _fetchAndDisplayPets();
          },
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onCameraIdle: _onCameraIdle,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
        ),
        // Zoom controls
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              FloatingActionButton(
                mini: true,
                heroTag: 'zoom_in',
                backgroundColor: theme.colors.accent,
                child: Icon(
                  CupertinoIcons.plus,
                  color: theme.colors.accentForeground,
                ),
                onPressed: () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                },
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                heroTag: 'zoom_out',
                backgroundColor: theme.colors.accent,
                child: Icon(
                  CupertinoIcons.minus,
                  color: theme.colors.accentForeground,
                ),
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
