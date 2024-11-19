import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:find_your_pet/models/location_info.dart';
import 'package:find_your_pet/models/pet_status.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class ListFilterSelectorSheet extends StatefulWidget {
  final PetStatus currentStatus;
  final Function(PetStatus) onStatusChanged;

  const ListFilterSelectorSheet({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  State<ListFilterSelectorSheet> createState() =>
      _ListFilterSelectorSheetState();
}

class _ListFilterSelectorSheetState extends State<ListFilterSelectorSheet> {
  GoogleMapController? _mapController;
  Set<Circle> _circles = {};
  Set<Marker> _markers = {};
  late double _radius;
  late LatLng _center;
  String _centerAddress = '';
  final TextEditingController _searchController = TextEditingController();
  bool _mapInitialized = false;
  late PetStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
    final locationProvider = context.read<LocationProvider>();
    final locationInfo = locationProvider.locationInfo;

    _radius = locationProvider.radius;
    _center = locationInfo != null
        ? LatLng(locationInfo.latitude, locationInfo.longitude)
        : const LatLng(37.7749, -122.4194);
    _centerAddress = locationInfo?.displayName ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('center'),
          position: _center,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      };
    });
  }

  Future<void> _updateMapCenter(LatLng position) async {
    setState(() => _center = position);
    _updateCircle();
    _updateMarker();

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          _centerAddress = _formatAddress(placemarks.first);
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }

    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(position, _getZoomLevel(_radius)),
      );
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        await _updateMapCenter(LatLng(
          locations.first.latitude,
          locations.first.longitude,
        ));
      }
    } catch (e) {
      print('Error searching location: $e');
      _showError('Could not find location. Please try a different search.');
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permissions are denied.');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      await _updateMapCenter(LatLng(
        position.latitude,
        position.longitude,
      ));
    } catch (e) {
      print('Error getting current location: $e');
      _showError('Could not get current location.');
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _formatAddress(Placemark place) {
    final List<String> addressComponents = [];

    if (place.thoroughfare?.isNotEmpty == true) {
      addressComponents.add(place.thoroughfare!);
    }
    if (place.locality?.isNotEmpty == true) {
      addressComponents.add(place.locality!);
    }
    if (place.postalCode?.isNotEmpty == true) {
      addressComponents.add(place.postalCode!);
    }

    return addressComponents.isNotEmpty
        ? addressComponents.join(', ')
        : 'Unknown location';
  }

  double _getZoomLevel(double radius) {
    if (radius <= 1) return 14;
    if (radius <= 2) return 13.4;
    if (radius <= 3) return 12.8;
    if (radius <= 4) return 12.2;
    if (radius <= 5) return 11.6;
    if (radius <= 6) return 11.5;
    if (radius <= 7) return 11.4;
    if (radius <= 8) return 11.3;
    if (radius <= 9) return 11.2;
    return 11;
  }

  void _updateCircle() {
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId('searchArea'),
          center: _center,
          radius: _radius * 1609.34,
          fillColor: const Color(0x30006666),
          strokeColor: const Color(0xFF006666),
          strokeWidth: 1,
        ),
      };
    });
  }

  void _initializeMap(GoogleMapController controller) {
    if (!_mapInitialized) {
      _mapController = controller;
      final theme = context.read<ThemeProvider>();
      controller.setMapStyle(theme.getGoogleMapStyle());
      controller.moveCamera(
        CameraUpdate.newLatLngZoom(_center, _getZoomLevel(_radius)),
      );
      _updateCircle();
      _updateMarker();
      _mapInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final locationProvider = context.watch<LocationProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.colors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Icon(
                    CupertinoIcons.xmark,
                    color: theme.colors.secondaryForeground,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: _getZoomLevel(_radius),
              ),
              circles: _circles,
              markers: _markers,
              onMapCreated: _initializeMap,
              onCameraMove: (position) {
                setState(() => _center = position.target);
                _updateCircle();
                _updateMarker();
              },
              onCameraIdle: () {
                _updateMapCenter(_center);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colors.card,
            child: Column(
              children: [
                // Status buttons row
                Row(
                  children: [
                    for (var status in [
                      PetStatus.lost,
                      PetStatus.both,
                      PetStatus.found
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: _status == status
                                ? theme.colors.primary
                                : theme.colors.background,
                            borderRadius: BorderRadius.circular(8),
                            onPressed: () {
                              setState(() => _status = status);
                              widget.onStatusChanged(status);
                            },
                            child: Text(
                              status == PetStatus.both
                                  ? 'BOTH'
                                  : status.name.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _status == status
                                    ? theme.colors.primaryForeground
                                    : theme.colors.foreground,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search bar row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colors.border,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colors.border.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Icon(
                                CupertinoIcons.search,
                                color: theme.colors.secondaryForeground,
                              ),
                            ),
                            Expanded(
                              child: CupertinoTextField(
                                controller: _searchController,
                                placeholder: 'Enter zipcode',
                                decoration: null,
                                style:
                                    TextStyle(color: theme.colors.foreground),
                                onSubmitted: _searchLocation,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: theme.colors.border.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: theme.colors.primary,
                        borderRadius: BorderRadius.circular(8),
                        onPressed: () =>
                            _searchLocation(_searchController.text),
                        child: Text(
                          'Search',
                          style: TextStyle(
                            color: theme.colors.primaryForeground,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Current location button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: theme.colors.border.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _useCurrentLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colors.background,
                        border: Border.all(
                          color: theme.colors.border,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.location,
                            color: theme.colors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Current location',
                            style: TextStyle(
                              color: theme.colors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colors.card,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select a distance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colors.foreground,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoSlider(
                        value: _radius,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (value) {
                          setState(() {
                            _radius = value;
                            _updateMapCenter(_center);
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${_radius.round()} mi',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: theme.colors.border.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: theme.colors.primary,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: () {
                      locationProvider.updateLocation(
                        LocationInfo(
                          latitude: _center.latitude,
                          longitude: _center.longitude,
                          displayName: _centerAddress,
                          isCurrentLocation: false,
                        ),
                        _radius,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Show results',
                      style: TextStyle(
                        color: theme.colors.primaryForeground,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
