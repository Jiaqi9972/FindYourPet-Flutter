// lib/provider/theme_provider.dart
import 'package:flutter/cupertino.dart';
import 'package:find_your_pet/utils/color.dart';
import 'package:find_your_pet/utils/color_dark.dart';

class ColorPalette {
  // Base Colors
  final Color background; // Background color
  final Color foreground; // Foreground color (text)

  // Card Colors
  final Color card; // Card background color
  final Color cardForeground; // Card text color

  // Popover Colors
  final Color popover; // Popover background color
  final Color popoverForeground; // Popover text color

  // Primary Colors
  final Color primary; // Primary color
  final Color primaryForeground; // Primary text color

  // Secondary Colors
  final Color secondary; // Secondary color
  final Color secondaryForeground; // Secondary text color

  // Muted Colors
  final Color muted; // Muted background color
  final Color mutedForeground; // Muted text color

  // Accent Colors
  final Color accent; // Accent color
  final Color accentForeground; // Accent text color

  // Destructive Colors
  final Color destructive; // Destructive action color
  final Color destructiveForeground; // Destructive text color

  // Border Color
  final Color border; // Border color

  // Input Color
  final Color input; // Input field background color

  // Ring Color
  final Color ring; // Focus ring color

  // Google Map Style
  final String googleMapStyle;

  const ColorPalette({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.border,
    required this.input,
    required this.ring,
    required this.googleMapStyle,
  });
}

const lightPalette = ColorPalette(
  background: AppColors.background,
  foreground: AppColors.foreground,
  card: AppColors.card,
  cardForeground: AppColors.cardForeground,
  popover: AppColors.popover,
  popoverForeground: AppColors.popoverForeground,
  primary: AppColors.primary,
  primaryForeground: AppColors.primaryForeground,
  secondary: AppColors.secondary,
  secondaryForeground: AppColors.secondaryForeground,
  muted: AppColors.muted,
  mutedForeground: AppColors.mutedForeground,
  accent: AppColors.accent,
  accentForeground: AppColors.accentForeground,
  destructive: AppColors.destructive,
  destructiveForeground: AppColors.destructiveForeground,
  border: AppColors.border,
  input: AppColors.input,
  ring: AppColors.ring,
  googleMapStyle: AppColors.googleMapStyle,
);

const darkPalette = ColorPalette(
  background: AppColorsDark.background,
  foreground: AppColorsDark.foreground,
  card: AppColorsDark.card,
  cardForeground: AppColorsDark.cardForeground,
  popover: AppColorsDark.popover,
  popoverForeground: AppColorsDark.popoverForeground,
  primary: AppColorsDark.primary,
  primaryForeground: AppColorsDark.primaryForeground,
  secondary: AppColorsDark.secondary,
  secondaryForeground: AppColorsDark.secondaryForeground,
  muted: AppColorsDark.muted,
  mutedForeground: AppColorsDark.mutedForeground,
  accent: AppColorsDark.accent,
  accentForeground: AppColorsDark.accentForeground,
  destructive: AppColorsDark.destructive,
  destructiveForeground: AppColorsDark.destructiveForeground,
  border: AppColorsDark.border,
  input: AppColorsDark.input,
  ring: AppColorsDark.ring,
  googleMapStyle: AppColorsDark.googleMapStyle,
);

class ThemeProvider with ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  ColorPalette get colors => isDarkMode ? darkPalette : lightPalette;

  CupertinoThemeData getAppTheme() {
    return CupertinoThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: colors.primary, // Primary color for interactive elements
      scaffoldBackgroundColor:
          colors.background, // Background color for screens
      textTheme: CupertinoTextThemeData(
        // Primary text style for most content
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: colors.foreground,
        ),
        // Text style for buttons and links
        actionTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: colors.primaryForeground,
        ),
        // Text style for tab labels
        tabLabelTextStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.normal,
          color: colors.mutedForeground,
        ),
        // Text style for navigation titles
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: colors.foreground,
        ),
        // Text style for large navigation titles
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: colors.foreground,
        ),
        // Text style for date and time pickers
        dateTimePickerTextStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.normal,
          color: colors.foreground,
        ),
        // Text style for pickers
        pickerTextStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.normal,
          color: colors.foreground,
        ),
      ),
      barBackgroundColor: colors.card, // Background color for navigation bars
      primaryContrastingColor:
          colors.primaryForeground, // Contrasting color for nav elements
    );
  }

  String getGoogleMapStyle() {
    return colors.googleMapStyle;
  }
}
