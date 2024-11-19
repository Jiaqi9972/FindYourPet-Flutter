import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'list_page.dart';
import 'map_page.dart';

class FindPage extends StatefulWidget {
  const FindPage({Key? key}) : super(key: key);

  @override
  _FindPageState createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  String _searchQuery = '';
  Map<String, dynamic> _filters = {
    'lost': null, // null means no filter on lost or found
  };
  Position? _currentPosition;
  double _radiusInMiles = 5.0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Get user's location
  void _getUserLocation() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) {
      setState(() {
        _currentPosition = Position(
          longitude: -122.4194,
          latitude: 37.7749,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        _filters['latitude'] = _currentPosition!.latitude;
        _filters['longitude'] = _currentPosition!.longitude;
        _filters['radiusInMiles'] = _radiusInMiles;
      });
      return;
    }

    try {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      setState(() {
        _currentPosition = position;
        _filters['latitude'] = _currentPosition!.latitude;
        _filters['longitude'] = _currentPosition!.longitude;
        _filters['radiusInMiles'] = _radiusInMiles;
      });
    } catch (e) {
      print('Error getting user location: $e');
      _showAlert('Unable to get location. Using default location.');
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
              'Location services are required to show pets nearby. Please enable location services in Settings.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text('Settings'),
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openLocationSettings();
              },
            ),
          ],
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Location Permission'),
            content: const Text(
                'Location permission is required to show pets nearby. Would you like to enable it?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: const Text('Settings'),
                onPressed: () {
                  Navigator.pop(context);
                  Geolocator.openAppSettings();
                },
              ),
            ],
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Location Permission'),
          content: const Text(
              'Location permissions are permanently denied. Please enable them in your phone settings.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text('Settings'),
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings();
              },
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }

  // Alert user
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

  // Called when map zoom changes
  void _onMapZoomChanged(double zoom) {
    setState(() {
      _radiusInMiles = _zoomToRadius(zoom);
      _filters['radiusInMiles'] = _radiusInMiles;
    });
  }

  // Update list when the map's position changes
  void _onMapPositionChanged(Position position) {
    setState(() {
      _currentPosition = position;
      _filters['latitude'] = position.latitude;
      _filters['longitude'] = position.longitude;
    });
  }

  double _zoomToRadius(double zoom) {
    return 5.0 / pow(2, (zoom - 12).round());
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          MapPage(
            searchQuery: _searchQuery,
            filters: _filters,
            currentPosition: _currentPosition,
            onMapPositionChanged: _onMapPositionChanged,
            onMapZoomChanged: _onMapZoomChanged,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 6,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoSearchTextField(
                              placeholder: 'Search pets',
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                  _filters['searchQuery'] = _searchQuery;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child:
                                const Icon(CupertinoIcons.slider_horizontal_3),
                            onPressed: () {
                              // Open filter page
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListPage(
                        searchQuery: _searchQuery,
                        filters: _filters,
                        scrollController: scrollController,
                        currentPosition: _currentPosition,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
