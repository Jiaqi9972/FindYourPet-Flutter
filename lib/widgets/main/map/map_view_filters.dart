// lib/widgets/main/map/map_view_filters.dart

import 'package:find_your_pet/models/view_mode.dart';
import 'package:find_your_pet/widgets/main/view_mode_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:find_your_pet/models/pet_status.dart';
import 'package:find_your_pet/pages/add_pet/cupertino_autocomplete_address.dart';

const String googleApiKey = "AIzaSyDn7prRSwmECvKMeo_3HhYZYNBNahcd5oo";

class MapViewFilters extends StatefulWidget {
  final PetStatus currentStatus;
  final Function(PetStatus) onStatusChanged;
  final ViewMode currentView;
  final Function(ViewMode) onViewModeChanged;
  final Function(double, double, String) onAddressChanged;

  const MapViewFilters({
    Key? key,
    required this.currentStatus,
    required this.onStatusChanged,
    required this.currentView,
    required this.onViewModeChanged,
    required this.onAddressChanged,
  }) : super(key: key);

  @override
  _MapViewFiltersState createState() => _MapViewFiltersState();
}

class _MapViewFiltersState extends State<MapViewFilters> {
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final locationProvider = context.read<LocationProvider>();
    _addressController = TextEditingController(
      text: locationProvider.locationInfo?.displayName ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant MapViewFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Optionally, you can handle updates if needed
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showStatusSelector(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    final themeData = theme.getAppTheme();
    PetStatus tempSelectedStatus = widget.currentStatus;
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: themeData.scaffoldBackgroundColor,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colors.card,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: theme.colors.accentForeground),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Select Status',
                    style: themeData.textTheme.navTitleTextStyle,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Done',
                      style: TextStyle(color: theme.colors.accentForeground),
                    ),
                    onPressed: () {
                      widget.onStatusChanged(tempSelectedStatus);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: themeData.scaffoldBackgroundColor,
                itemExtent: 32.0,
                scrollController: FixedExtentScrollController(
                  initialItem: PetStatus.values.indexOf(widget.currentStatus),
                ),
                onSelectedItemChanged: (index) {
                  tempSelectedStatus = PetStatus.values[index];
                },
                children: PetStatus.values.map((status) {
                  return Center(
                    child: Text(
                      status.name.toUpperCase(),
                      style: themeData.textTheme.textStyle,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddressSelected(double lat, double lng, String address) {
    // Update the text in the controller
    setState(() {
      _addressController.text = address;
    });
    // Call the callback to update the map
    widget.onAddressChanged(lat, lng, address);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Container(
      color: theme.colors.card.withOpacity(0.8),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // View Mode Switcher
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ViewModeSwitcher(
                currentView: widget.currentView,
                onViewModeChanged: widget.onViewModeChanged,
              ),
            ),
            // Address Input and Status Selector
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: Row(
                children: [
                  // Address Autocomplete Input
                  Expanded(
                    child: CupertinoAddressAutocomplete(
                      apiKey: googleApiKey,
                      controller: _addressController,
                      onLocationSelected: _onAddressSelected,
                      textStyle: TextStyle(color: theme.colors.foreground),
                      backgroundColor: theme.colors.card,
                      clearButtonColor: theme.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Selector
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showStatusSelector(context),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.slider_horizontal_3,
                          color: theme.colors.foreground,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.currentStatus.name.toUpperCase(),
                          style: TextStyle(
                            color: theme.colors.foreground,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
