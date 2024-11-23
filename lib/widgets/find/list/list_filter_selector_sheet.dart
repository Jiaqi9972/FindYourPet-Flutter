import 'package:find_your_pet/models/list_location_info.dart';
import 'package:find_your_pet/provider/pet_status_provider.dart';
import 'package:find_your_pet/styles/color/app_colors_config.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/styles/ui/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:find_your_pet/models/pet_status.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class ListFilterSelectorSheet extends StatefulWidget {
  const ListFilterSelectorSheet({super.key});

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
  bool _mapInitialized = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final locationProvider = context.read<LocationProvider>();
    final listLocation = locationProvider.listLocationInfo;

    _radius = listLocation?.radius ?? 5.0;
    _center = listLocation != null
        ? LatLng(listLocation.latitude, listLocation.longitude)
        : const LatLng(37.7749, -122.4194);

    if (listLocation != null) {
      _centerAddress = listLocation.displayName;
    }

    _updateCircle();
    _updateMarker();
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
      if (locations.isNotEmpty && mounted) {
        setState(() {
          _center = LatLng(locations.first.latitude, locations.first.longitude);
          _centerAddress = query;
          _updateCircle();
          _updateMarker();
        });

        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_center, _getZoomLevel(_radius)),
          );
        }

        context.read<LocationProvider>().updateListLocation(
              ListLocationInfo(
                latitude: locations.first.latitude,
                longitude: locations.first.longitude,
                displayName: query,
                radius: _radius,
              ),
            );
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

      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _centerAddress = 'Current Location';
        _updateCircle();
        _updateMarker();
      });

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_center, _getZoomLevel(_radius)),
        );
      }

      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      locationProvider.updateListLocation(
        ListLocationInfo(
          latitude: position.latitude,
          longitude: position.longitude,
          displayName: 'Current Location',
        ),
      );
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
      final isDarkMode = context.read<ThemeProvider>().isDarkMode;
      final colors = AppColorsConfig.getTheme(isDarkMode);
      controller.setMapStyle(colors.googleMapStyle);
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
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);

    final locationProvider = context.watch<LocationProvider>();
    final statusProvider = context.watch<PetStatusProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          // Header with title and close button
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
                      color: colors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Icon(
                    CupertinoIcons.xmark,
                    color: colors.secondaryForeground,
                  ),
                ),
              ],
            ),
          ),

          // Google Map for filter visualization
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

          // Filters section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colors.background,
            child: Column(
              children: [
                // Status selection buttons
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
                          child: AppButton(
                            text: status == PetStatus.both
                                ? 'BOTH'
                                : status.name.toUpperCase(),
                            variant: statusProvider.currentStatus == status
                                ? ButtonVariant.primary
                                : ButtonVariant.outline,
                            isDarkMode: isDarkMode,
                            fullWidth: true,
                            onPressed: () =>
                                statusProvider.updateStatus(status),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.border,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.border.withOpacity(0.2),
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
                                color: colors.secondaryForeground,
                              ),
                            ),
                            Expanded(
                              child: CupertinoTextField(
                                controller: _searchController,
                                placeholder: 'Enter street, city, or ZIP code',
                                decoration: null,
                                style: TextStyle(color: colors.foreground),
                                onSubmitted: _searchLocation,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Search',
                      variant: ButtonVariant.primary,
                      isDarkMode: isDarkMode,
                      onPressed: () => _searchLocation(_searchController.text),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Current location button
                AppButton(
                  text: 'Current location',
                  icon: CupertinoIcons.location,
                  variant: ButtonVariant.outline,
                  fullWidth: true,
                  isDarkMode: isDarkMode,
                  onPressed: _useCurrentLocation,
                ),
              ],
            ),
          ),

          // Distance slider and apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.background,
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
                    color: colors.foreground,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoSlider(
                        activeColor: colors.primary,
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
                AppButton(
                  text: 'Show results',
                  fullWidth: true,
                  onPressed: () {
                    locationProvider.updateListLocation(
                      ListLocationInfo(
                        latitude: _center.latitude,
                        longitude: _center.longitude,
                        displayName: _centerAddress,
                        radius: _radius,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  variant: ButtonVariant.primary,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
