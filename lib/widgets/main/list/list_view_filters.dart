// lib/widgets/main/list/list_view_filters.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:find_your_pet/models/pet_status.dart';
import 'package:find_your_pet/widgets/main/location_selector_sheet.dart';

class ListViewFilters extends StatelessWidget {
  final PetStatus currentStatus;
  final Function(PetStatus) onStatusChanged;

  const ListViewFilters({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  void _showLocationSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const LocationSelectorSheet(),
    );
  }

  void _showStatusSelector(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    final themeData = theme.getAppTheme();

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
                      style: TextStyle(color: theme.colors.cardForeground),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: themeData.scaffoldBackgroundColor,
                itemExtent: 32.0,
                onSelectedItemChanged: (index) {
                  onStatusChanged(PetStatus.values[index]);
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

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final locationProvider = context.watch<LocationProvider>();

    return Container(
      color: theme.colors.card.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Location button
          Expanded(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showLocationSelector(context),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.location,
                    color: theme.colors.cardForeground,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationProvider.locationInfo?.displayName ??
                          'Current Location',
                      style: TextStyle(
                        color: theme.colors.cardForeground,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Radius display
          Text(
            'Within ${locationProvider.radius.toInt()} miles',
            style: TextStyle(
              color: theme.colors.cardForeground,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          // Status selector
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showStatusSelector(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colors.card,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: theme.colors.cardForeground,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentStatus.name.toUpperCase(),
                    style: TextStyle(
                      color: theme.colors.cardForeground,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
