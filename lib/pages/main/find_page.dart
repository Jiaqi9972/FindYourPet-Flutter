// lib/pages/main/find_page.dart

import 'package:find_your_pet/widgets/main/view_mode_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/models/location_info.dart';
import 'package:find_your_pet/models/view_mode.dart';
import 'package:find_your_pet/models/pet_status.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:find_your_pet/widgets/main/list/list_view_filters.dart';
import 'package:find_your_pet/widgets/main/map/map_view_filters.dart';
import 'package:find_your_pet/widgets/main/pet_list_view.dart';
import 'package:find_your_pet/widgets/main/pet_map_view.dart';

class FindPage extends StatefulWidget {
  const FindPage({super.key});

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  ViewMode _currentView = ViewMode.list;
  PetStatus _currentStatus = PetStatus.all;
  final Map<String, dynamic> _filters = {
    'lost': null,
    'radiusInMiles': 5.0,
  };

  // Map center position
  double? _mapCenterLat;
  double? _mapCenterLng;

  @override
  void initState() {
    super.initState();
    // Initialize location
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.initCurrentLocation();

      final locationInfo = locationProvider.locationInfo;

      if (locationInfo != null) {
        setState(() {
          _mapCenterLat = locationInfo.latitude;
          _mapCenterLng = locationInfo.longitude;
        });
      } else {
        // Set default coordinates if locationInfo is null
        setState(() {
          _mapCenterLat = 37.7749; // Example: San Francisco latitude
          _mapCenterLng = -122.4194; // San Francisco longitude
        });
      }
    });
  }

  void _updateFilters(LocationInfo location) {
    setState(() {
      _filters['latitude'] = location.latitude;
      _filters['longitude'] = location.longitude;
    });
  }

  void _onStatusChanged(PetStatus status) {
    setState(() {
      _currentStatus = status;
      switch (status) {
        case PetStatus.all:
          _filters['lost'] = null;
          break;
        case PetStatus.lost:
          _filters['lost'] = true;
          break;
        case PetStatus.found:
          _filters['lost'] = false;
          break;
      }
    });
  }

  void _onViewModeChanged(ViewMode mode) {
    setState(() {
      _currentView = mode;
    });
  }

  void _onAddressChanged(double lat, double lng, String address) {
    setState(() {
      _mapCenterLat = lat;
      _mapCenterLng = lng;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final locationProvider = context.watch<LocationProvider>();

    // Update filters
    if (locationProvider.locationInfo != null) {
      _updateFilters(locationProvider.locationInfo!);
      _filters['radiusInMiles'] = locationProvider.radius;
    }

    // Check if map center coordinates are available
    if (_mapCenterLat == null || _mapCenterLng == null) {
      // Show loading indicator
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: theme.colors.background,
      child: _currentView == ViewMode.list
          ? Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // View Mode Switcher
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ViewModeSwitcher(
                          currentView: _currentView,
                          onViewModeChanged: _onViewModeChanged,
                        ),
                      ),
                      // Location and Status Filters
                      ListViewFilters(
                        currentStatus: _currentStatus,
                        onStatusChanged: _onStatusChanged,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PetListView(
                    filters: _filters,
                    locationInfo: locationProvider.locationInfo,
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: PetMapView(
                    filters: {
                      'lost': _filters['lost'],
                    },
                    initialLat: _mapCenterLat!,
                    initialLng: _mapCenterLng!,
                    // Remove or comment out the onMapPositionChanged callback
                    // onMapPositionChanged: (lat, lng) {},
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: MapViewFilters(
                    currentStatus: _currentStatus,
                    onStatusChanged: _onStatusChanged,
                    currentView: _currentView,
                    onViewModeChanged: _onViewModeChanged,
                    onAddressChanged: _onAddressChanged,
                  ),
                ),
              ],
            ),
    );
  }
}
