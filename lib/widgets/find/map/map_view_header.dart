import 'package:find_your_pet/models/view_mode.dart';
import 'package:find_your_pet/widgets/find/map/map_filter_selector_sheet.dart';
import 'package:find_your_pet/widgets/find/view_mode_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:find_your_pet/models/pet_status.dart';

class MapViewHeader extends StatelessWidget {
  final PetStatus currentStatus;
  final Function(PetStatus) onStatusChanged;
  final ViewMode currentView;
  final Function(ViewMode) onViewModeChanged;
  final Function(double, double, String) onAddressChanged;

  const MapViewHeader({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    required this.currentView,
    required this.onViewModeChanged,
    required this.onAddressChanged,
  });

  void _showFilterSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => MapFilterSelector(
        currentStatus: currentStatus,
        onStatusChanged: onStatusChanged,
        onAddressChanged: onAddressChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final locationProvider = context.watch<LocationProvider>();

    return Container(
      color: theme.colors.card.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ViewModeSwitcher(
                currentView: currentView,
                onViewModeChanged: onViewModeChanged,
              ),
            ),
            Row(
              children: [
                Icon(
                  CupertinoIcons.location_fill,
                  color: theme.colors.foreground,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationProvider.locationInfo?.displayName ??
                        'Select Location',
                    style: TextStyle(
                      color: theme.colors.foreground,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _showFilterSelector(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colors.secondary,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: theme.colors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.slider_horizontal_3,
                          color: theme.colors.secondaryForeground,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
