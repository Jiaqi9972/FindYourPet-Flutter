import 'package:find_your_pet/styles/color/app_colors_config.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/widgets/find/list/list_filter_selector_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/location_provider.dart';

class ListViewHeader extends StatelessWidget {
  const ListViewHeader({
    super.key,
  });

  void _showFilterSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => ListFilterSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);

    final locationProvider = context.watch<LocationProvider>();

    return Container(
      color: colors.background.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.location_fill,
            color: colors.foreground,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              locationProvider.listLocationInfo?.displayName ??
                  'Select Location',
              style: TextStyle(
                color: colors.foreground,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'Within ${locationProvider.listLocationInfo?.radius.toInt() ?? 5} miles',
            style: TextStyle(
              color: colors.foreground,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showFilterSelector(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: colors.secondary,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: colors.secondaryForeground,
                    size: 16,
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
