import 'dart:math';
import 'dart:ui' as ui;
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/lost_pet.dart';
import '../api/api_service.dart';
import 'package:flutter/services.dart';
import 'pet_detail_page.dart';

class MapPage extends StatefulWidget {
  final String searchQuery;
  final Map<String, dynamic> filters;
  final ValueChanged<Position> onMapPositionChanged;
  final ValueChanged<double> onMapZoomChanged;
  final Position? currentPosition;

  const MapPage({
    Key? key,
    required this.searchQuery,
    required this.filters,
    required this.onMapZoomChanged,
    required this.onMapPositionChanged,
    required this.currentPosition,
  }) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final ApiService _apiService = ApiService();
  double _currentZoom = 12.0;
  Position? _currentPosition;
  final Map<bool, BitmapDescriptor> _markerIcons = {};
  LostPet? _selectedPet;

  @override
  void initState() {
    super.initState();
    if (widget.currentPosition != null) {
      _currentPosition = widget.currentPosition;
    }
  }

  // Called when the camera stops moving to update the position and radius
  void _onCameraIdle() async {
    LatLngBounds bounds = await _mapController!.getVisibleRegion();
    double latitude =
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
    double longitude =
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2;

    // Calculate the visible radius from the map bounds
    double radius = _calculateVisibleRadius(bounds);

    // Create a new position object
    Position newPosition = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 1.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 1.0,
      altitudeAccuracy: 1.0,
      headingAccuracy: 1.0,
      isMocked: false,
    );

    // Update the current position and filters
    setState(() {
      _currentPosition = newPosition;
      widget.filters['latitude'] = newPosition.latitude;
      widget.filters['longitude'] = newPosition.longitude;
      widget.filters['radiusInMiles'] = radius;
    });

    // Call the callback to notify the parent (FindPage)
    widget.onMapPositionChanged(newPosition);

    // Fetch new pets for both the map and the list
    _fetchAndDisplayLostPets();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });

      _fetchAndDisplayLostPets();
    } catch (e) {
      print('Error getting user location: $e');
      _showAlert(
          'Unable to get current location. Please enable location services.');
    }
  }

  void _showAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // Handle marker tap to show the popup
  void _onMarkerTapped(LostPet pet) {
    setState(() {
      _selectedPet = pet;
    });
  }

  Future<void> _fetchAndDisplayLostPets() async {
    if (_currentPosition == null) return;

    try {
      double latitude = _currentPosition!.latitude;
      double longitude = _currentPosition!.longitude;
      double radiusInMiles = widget.filters['radiusInMiles'] ?? 5.0;
      bool? lost = widget.filters['lost'];

      List<LostPet> pets = await _apiService.fetchLostPetsForMap(
        latitude,
        longitude,
        radiusInMiles,
        lost,
      );

      print("Fetch triggered");

      Set<Marker> newMarkers = {};

      for (var pet in pets) {
        BitmapDescriptor markerIcon = await _getMarkerIcon(pet.lost);

        Marker marker = Marker(
          markerId: MarkerId(pet.id),
          position: LatLng(pet.latitude, pet.longitude),
          icon: markerIcon,
          onTap: () {
            _onMarkerTapped(pet);
          },
        );

        newMarkers.add(marker);
      }

      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
      });
    } catch (e) {
      print('Error fetching lost pets: $e');
    }
  }

  Future<BitmapDescriptor> _getMarkerIcon(bool lost) async {
    if (_markerIcons.containsKey(lost)) {
      return _markerIcons[lost]!;
    }

    String assetName =
        lost ? 'assets/images/lost_pin.png' : 'assets/images/found_pin.png';
    ByteData data = await rootBundle.load(assetName);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 80,
      targetHeight: 80,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    ByteData? bytes = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw Exception('Unable to convert image to bytes');
    }
    BitmapDescriptor icon =
        BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
    _markerIcons[lost] = icon;
    return icon;
  }

  double _calculateVisibleRadius(LatLngBounds bounds) {
    final double lat1 = bounds.southwest.latitude;
    final double lon1 = bounds.southwest.longitude;
    final double lat2 = bounds.northeast.latitude;
    final double lon2 = bounds.northeast.longitude;

    const double earthRadiusMiles = 3958.8;
    double latDistance = _degreeToRadian(lat2 - lat1);
    double lonDistance = _degreeToRadian(lon2 - lon1);

    double a = sin(latDistance / 2) * sin(latDistance / 2) +
        cos(_degreeToRadian(lat1)) *
            cos(_degreeToRadian(lat2)) *
            sin(lonDistance / 2) *
            sin(lonDistance / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadiusMiles * c;

    return distance / 2; // The radius is half of the diagonal distance
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  void _zoomIn() {
    _currentZoom += 1;
    _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoom));
    widget.onMapZoomChanged(_currentZoom); // Notify parent of zoom change
  }

  void _zoomOut() {
    _currentZoom -= 1;
    _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoom));
    widget.onMapZoomChanged(_currentZoom); // Notify parent of zoom change
  }

  Widget _buildZoomButtons() {
    return Positioned(
      right: 10,
      top: 100,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            onPressed: _zoomIn,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            onPressed: _zoomOut,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _buildPetDetailPopup() {
    return Positioned(
      top:
          100, // Change this value to control how far above the marker the popup appears
      left: 20,
      right: 20,
      child: CupertinoPopupSurface(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedPet!.name,
                style:
                    CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${_selectedPet!.lost ? 'Lost' : 'Found'}',
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              const SizedBox(height: 8),
              if (_selectedPet!.petImageUrl != null)
                Text(
                  _selectedPet!.petImageUrl!,
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .copyWith(color: CupertinoColors.activeBlue),
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    child: const Text('Details'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              PetDetailPage(petId: _selectedPet!.id),
                        ),
                      );
                    },
                  ),
                  CupertinoButton(
                    child: const Text('Close'),
                    onPressed: () {
                      setState(() {
                        _selectedPet = null;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: _currentZoom,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            _fetchAndDisplayLostPets();
          },
          style: themeProvider.getGoogleMapStyle(),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onCameraMove: (CameraPosition position) {
            _currentZoom = position.zoom;
            widget.onMapZoomChanged(_currentZoom); // Notify zoom change
          },
          onCameraIdle: _onCameraIdle, // Trigger when map dragging ends
          onTap: (position) {
            setState(() {
              _selectedPet = null; // Close popup when the map is tapped
            });
          },
        ),
        if (_selectedPet != null) _buildPetDetailPopup(),
        _buildZoomButtons(),
      ],
    );
  }
}
