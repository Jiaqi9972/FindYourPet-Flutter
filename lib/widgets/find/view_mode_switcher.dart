// lib/widgets/main/view_mode_switcher.dart

import 'package:find_your_pet/models/view_mode.dart';
import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

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
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return SizedBox(
      height: 40,
      width: double.infinity,
      child: CupertinoSegmentedControl<ViewMode>(
        groupValue: currentView,
        onValueChanged: onViewModeChanged,
        selectedColor: isDarkMode ? AppColorsDark.primary : AppColors.primary,
        unselectedColor: isDarkMode ? AppColorsDark.muted : AppColors.muted,
        borderColor: isDarkMode ? AppColorsDark.border : AppColors.border,
        children: {
          ViewMode.list: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'List',
              style: TextStyle(
                fontSize: 16,
                color: currentView == ViewMode.list
                    ? (isDarkMode
                        ? AppColorsDark.primaryForeground
                        : AppColors.primaryForeground)
                    : (isDarkMode
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground),
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
                    ? (isDarkMode
                        ? AppColorsDark.primaryForeground
                        : AppColors.primaryForeground)
                    : (isDarkMode
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground),
              ),
            ),
          ),
        },
      ),
    );
  }
}
