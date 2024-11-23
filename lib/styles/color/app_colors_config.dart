import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:flutter/cupertino.dart';

class AppColorsConfig {
  final Color background;
  final Color foreground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color destructiveForeground;
  final Color border;
  final Color input;
  final String googleMapStyle;

  const AppColorsConfig({
    required this.background,
    required this.foreground,
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
    required this.googleMapStyle,
  });

  // 提供明暗模式的静态实例
  static AppColorsConfig light = const AppColorsConfig(
    background: AppColors.background,
    foreground: AppColors.foreground,
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
    googleMapStyle: AppColors.googleMapStyle,
  );

  static AppColorsConfig dark = const AppColorsConfig(
    background: AppColorsDark.background,
    foreground: AppColorsDark.foreground,
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
    googleMapStyle: AppColorsDark.googleMapStyle,
  );

  // 根据主题返回对应的配置
  static AppColorsConfig getTheme(bool isDarkMode) {
    return isDarkMode ? dark : light;
  }
}
