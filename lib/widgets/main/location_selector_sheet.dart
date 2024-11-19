// lib/widgets/main/location_selector_sheet.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:find_your_pet/models/location_info.dart';
import 'package:find_your_pet/pages/add_pet/cupertino_autocomplete_address.dart';

const String googleApiKey = "AIzaSyDn7prRSwmECvKMeo_3HhYZYNBNahcd5oo";

class LocationSelectorSheet extends StatelessWidget {
  const LocationSelectorSheet({super.key});

  Future<void> _useCurrentLocation(BuildContext context) async {
    try {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.initCurrentLocation();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error using current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final themeData = theme.getAppTheme();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      color: themeData.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colors.card,
              border: Border(
                bottom: BorderSide(
                  color: theme.colors.border,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: theme.colors.cardForeground),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Select Location',
                  style: themeData.textTheme.navTitleTextStyle,
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'Done',
                    style: TextStyle(color: theme.colors.cardForeground),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Location
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 50,
              child: CupertinoAddressAutocomplete(
                apiKey: googleApiKey,
                controller: TextEditingController(
                  text: locationProvider.locationInfo?.displayName ?? '',
                ),
                onLocationSelected: (lat, lng, address) {
                  locationProvider.updateLocation(
                    LocationInfo(
                      latitude: lat,
                      longitude: lng,
                      displayName: address,
                      isCurrentLocation: false,
                    ),
                    locationProvider.radius,
                  );
                },
                textStyle: themeData.textTheme.textStyle,
                backgroundColor: theme.colors.card,
                clearButtonColor: theme.colors.primary,
              ),
            ),
          ),

          // Current Location Button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _useCurrentLocation(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colors.card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.location,
                    color: theme.colors.cardForeground,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Use Current Location',
                    style: TextStyle(
                      color: theme.colors.cardForeground,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Radius Selector
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colors.card,
              border: Border(
                top: BorderSide(color: theme.colors.border),
                bottom: BorderSide(color: theme.colors.border),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Radius',
                  style: TextStyle(
                    color: theme.colors.cardForeground,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Within ${locationProvider.radius.toInt()} miles',
                      style: themeData.textTheme.textStyle,
                    ),
                    Expanded(
                      child: CupertinoSlider(
                        min: 1.0,
                        max: 50.0,
                        divisions: 49,
                        value: locationProvider.radius,
                        activeColor: theme.colors.cardForeground,
                        onChanged: (value) {
                          locationProvider.updateRadius(value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
