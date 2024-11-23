import 'package:find_your_pet/models/list_location_info.dart';
import 'package:find_your_pet/provider/pet_status_provider.dart';
import 'package:find_your_pet/provider/view_provider.dart';
import 'package:find_your_pet/styles/color/app_colors_config.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:find_your_pet/widgets/find/map/pet_map_view.dart';
import 'package:find_your_pet/widgets/find/view_mode_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/models/view_mode.dart';
import 'package:find_your_pet/models/pet_status.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:find_your_pet/widgets/find/list/list_view_header.dart';
import 'package:find_your_pet/widgets/find/map/map_view_header.dart';
import 'package:find_your_pet/widgets/find/list/pet_list_view.dart';

class FindPage extends StatefulWidget {
  const FindPage({super.key});

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  double? _mapCenterLat;
  double? _mapCenterLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationProvider = context.read<LocationProvider>();
      if (locationProvider.listLocationInfo == null) {
        locationProvider.updateListLocation(
          ListLocationInfo(
            latitude: 37.785834,
            longitude: -122.406417,
            displayName: 'San Francisco, CA',
            radius: 5.0,
          ),
        );
      }
      await locationProvider.initCurrentLocation();
      _updateLocationFromProvider(locationProvider);
    });
  }

  void _updateLocationFromProvider(LocationProvider provider) {
    final mapLocation = provider.mapLocationInfo;
    final listLocation = provider.listLocationInfo;

    if (mapLocation != null) {
      setState(() {
        _mapCenterLat = mapLocation.latitude;
        _mapCenterLng = mapLocation.longitude;
      });
    } else if (listLocation != null) {
      setState(() {
        _mapCenterLat = listLocation.latitude;
        _mapCenterLng = listLocation.longitude;
      });
    } else {
      setState(() {
        _mapCenterLat = 37.7749;
        _mapCenterLng = -122.4194;
      });
    }
  }

  void _onAddressChanged(double lat, double lng, String address) {
    setState(() {
      _mapCenterLat = lat;
      _mapCenterLng = lng;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);
    final locationProvider = context.watch<LocationProvider>();
    final viewModeProvider = context.watch<ViewModeProvider>();
    final statusProvider = context.watch<PetStatusProvider>();

    final filters = {
      'lost': statusProvider.currentStatus == PetStatus.both
          ? null
          : statusProvider.currentStatus == PetStatus.lost,
      'radiusInMiles': 5.0,
      'latitude': locationProvider.mapLocationInfo?.latitude ?? _mapCenterLat,
      'longitude': locationProvider.mapLocationInfo?.longitude ?? _mapCenterLng,
    };

    if (_mapCenterLat == null || _mapCenterLng == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Find Your Pet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        backgroundColor: colors.background,
      ),
      child: viewModeProvider.currentView == ViewMode.list
          ? Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ViewModeSwitcher(
                          currentView: viewModeProvider.currentView,
                          onViewModeChanged: (mode) =>
                              viewModeProvider.setViewMode(mode),
                        ),
                      ),
                      const ListViewHeader(),
                    ],
                  ),
                ),
                Expanded(
                  child: PetListView(
                    filters: filters,
                    listlocationInfo: locationProvider.listLocationInfo,
                  ),
                ),
              ],
            )
          : SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ViewModeSwitcher(
                      currentView: viewModeProvider.currentView,
                      onViewModeChanged: (mode) =>
                          viewModeProvider.setViewMode(mode),
                    ),
                  ),
                  MapViewHeader(
                    onAddressChanged: _onAddressChanged,
                  ),
                  Expanded(
                    child: PetMapView(
                      filters: filters,
                      initialLat: locationProvider.mapLocationInfo?.latitude ??
                          _mapCenterLat!,
                      initialLng: locationProvider.mapLocationInfo?.longitude ??
                          _mapCenterLng!,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
