// ThemeProvider.dart
import 'package:flutter/cupertino.dart';
import 'package:find_your_pet/utils/color.dart';
import 'package:find_your_pet/utils/color_dark.dart';

class ThemeProvider with ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  CupertinoThemeData getAppTheme() {
    return CupertinoThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: isDarkMode ? AppColorsDark.primary : AppColors.primary,
      scaffoldBackgroundColor:
          isDarkMode ? AppColorsDark.background : AppColors.background,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: isDarkMode ? AppColorsDark.foreground : AppColors.foreground,
        ),
      ),
      barBackgroundColor: isDarkMode ? AppColorsDark.card : AppColors.card,
      primaryContrastingColor: isDarkMode
          ? AppColorsDark.primaryForeground
          : AppColors.primaryForeground,
    );
  }

  String getGoogleMapStyle() {
    return isDarkMode ? AppColorsDark.googleMapStyle : AppColors.googleMapStyle;
  }
}
