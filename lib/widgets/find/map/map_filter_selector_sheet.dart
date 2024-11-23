import 'package:find_your_pet/models/map_location_info.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:find_your_pet/provider/pet_status_provider.dart';
import 'package:find_your_pet/styles/color/app_colors_config.dart';
import 'package:find_your_pet/styles/ui/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/models/pet_status.dart';
import 'package:geocoding/geocoding.dart';

class MapFilterSelector extends StatefulWidget {
  final Function(double, double, String) onAddressChanged;

  const MapFilterSelector({
    super.key,
    required this.onAddressChanged,
  });

  @override
  State<MapFilterSelector> createState() => _MapFilterSelectorState();
}

class _MapFilterSelectorState extends State<MapFilterSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = context.read<LocationProvider>();
      final mapLocation = locationProvider.mapLocationInfo;
      if (mapLocation != null) {
        _getPostalCode(mapLocation.latitude, mapLocation.longitude);
      }
    });
  }

  Future<void> _getPostalCode(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        if (place.postalCode?.isNotEmpty == true) {
          _searchController.text = place.postalCode!;
          _lastSearchQuery = place.postalCode!;
        }
      }
    } catch (e) {
      print('Error getting postal code: $e');
    }
  }

  void _applyChanges() async {
    final query = _searchController.text;

    if (query.isEmpty || query == _lastSearchQuery) {
      Navigator.pop(context);
      return;
    }

    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty && mounted) {
        final location = locations.first;
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        String displayName;
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // 只使用城市和州来显示
          displayName = [
            place.locality,
            place.administrativeArea,
          ].where((e) => e?.isNotEmpty == true).join(", ");
        } else {
          displayName = query;
        }

        widget.onAddressChanged(
            location.latitude, location.longitude, displayName);

        Provider.of<LocationProvider>(context, listen: false).updateMapLocation(
          MapLocationInfo(
            latitude: location.latitude,
            longitude: location.longitude,
            displayName: displayName,
            radiusInMiles: 5.0,
          ),
        );
      }
    } catch (e) {
      _showError('Could not find location. Please try again.');
      return;
    }

    _lastSearchQuery = query;
    Navigator.pop(context);
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);
    final statusProvider = context.watch<PetStatusProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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

            // Status Selection
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
                        fullWidth: true,
                        text: status == PetStatus.both
                            ? 'BOTH'
                            : status.name.toUpperCase(),
                        onPressed: () {
                          statusProvider.updateStatus(status);
                        },
                        variant: statusProvider.currentStatus == status
                            ? ButtonVariant.primary
                            : ButtonVariant.outline,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Search Bar
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(
                    color: colors.border.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, child) {
                  return Row(
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
                          placeholder: 'Enter ZIP code',
                          decoration: null,
                          style: TextStyle(color: colors.foreground),
                          onSubmitted: (_) => _applyChanges(),
                        ),
                      ),
                      if (value.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              CupertinoIcons.clear_circled_solid,
                              color: colors.secondaryForeground,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Apply Button
            AppButton(
              text: 'Apply',
              fullWidth: true,
              onPressed: _applyChanges,
              variant: ButtonVariant.primary,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }
}
