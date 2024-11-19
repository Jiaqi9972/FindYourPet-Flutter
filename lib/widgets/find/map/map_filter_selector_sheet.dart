import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/models/pet_status.dart';
import 'package:geocoding/geocoding.dart';

class MapFilterSelector extends StatefulWidget {
  final PetStatus currentStatus;
  final Function(PetStatus) onStatusChanged;
  final Function(double, double, String) onAddressChanged;

  const MapFilterSelector({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    required this.onAddressChanged,
  });

  @override
  State<MapFilterSelector> createState() => _MapFilterSelectorState();
}

class _MapFilterSelectorState extends State<MapFilterSelector> {
  final TextEditingController _searchController = TextEditingController();
  late PetStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        widget.onAddressChanged(
          locations.first.latitude,
          locations.first.longitude,
          query,
        );
      }
    } catch (e) {
      print('Error searching location: $e');
      _showError('Could not find location. Please try a different search.');
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

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

            // Search bar
            Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _searchController,
                    placeholder: 'Enter zipcode',
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(
                        CupertinoIcons.search,
                        color: theme.colors.secondaryForeground,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: theme.colors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colors.border,
                      ),
                    ),
                    style: TextStyle(color: theme.colors.foreground),
                    onSubmitted: _searchLocation,
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: theme.colors.primary,
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () => _searchLocation(_searchController.text),
                  child: Text(
                    'Search',
                    style: TextStyle(
                      color: theme.colors.primaryForeground,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Location button
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // Handle current location
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colors.background,
                  border: Border.all(
                    color: theme.colors.border,
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
          ],
        ),
      ),
    );
  }
}
