// lib/widgets/main/view_mode_switcher.dart

import 'package:find_your_pet/models/view_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';

class ViewModeSwitcher extends StatelessWidget {
  final ViewMode currentView;
  final Function(ViewMode) onViewModeChanged;

  const ViewModeSwitcher({
    super.key,
    required this.currentView,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return SizedBox(
      height: 40,
      width: double.infinity,
      child: CupertinoSegmentedControl<ViewMode>(
        groupValue: currentView,
        onValueChanged: onViewModeChanged,
        selectedColor: theme.colors.primary,
        unselectedColor: theme.colors.muted,
        borderColor: theme.colors.border,
        children: {
          ViewMode.list: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'List',
              style: TextStyle(
                fontSize: 16,
                color: currentView == ViewMode.list
                    ? theme.colors.primaryForeground
                    : theme.colors.mutedForeground,
              ),
            ),
          ),
          ViewMode.map: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Map',
              style: TextStyle(
                fontSize: 16,
                color: currentView == ViewMode.map
                    ? theme.colors.primaryForeground
                    : theme.colors.mutedForeground,
              ),
            ),
          ),
        },
      ),
    );
  }
}
