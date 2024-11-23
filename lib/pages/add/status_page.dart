import 'package:find_your_pet/styles/color/app_colors_config.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/styles/ui/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  final bool lost;
  final Function(bool) onStatusSelected;

  const StatusPage({
    super.key,
    required this.lost,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lost or Found?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.foreground,
            ),
          ),
          const SizedBox(height: 40),
          AppButton(
            text: 'I Lost a Pet',
            variant: ButtonVariant.primary,
            isDarkMode: isDarkMode,
            onPressed: () => onStatusSelected(true),
          ),
          const SizedBox(height: 20),
          AppButton(
            text: 'I Found a Pet',
            variant: ButtonVariant.primary,
            isDarkMode: isDarkMode,
            onPressed: () => onStatusSelected(false),
          ),
        ],
      ),
    );
  }
}
