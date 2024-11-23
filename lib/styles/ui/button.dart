import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:find_your_pet/styles/font/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, outline, muted, destructive, link }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isDarkMode;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isDarkMode = false,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  AppButton copyWith({
    String? text,
    VoidCallback? onPressed,
    ButtonVariant? variant,
    bool? isDarkMode,
    IconData? icon,
    bool? isLoading,
    bool? fullWidth,
  }) {
    return AppButton(
      text: text ?? this.text,
      onPressed: onPressed ?? this.onPressed,
      variant: variant ?? this.variant,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      icon: icon ?? this.icon,
      isLoading: isLoading ?? this.isLoading,
      fullWidth: fullWidth ?? this.fullWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor = _getForegroundColor();
    final backgroundColor = _getBackgroundColor();
    final boxShadow = _getBoxShadow();

    return CupertinoButton(
      onPressed: isLoading ? null : onPressed,
      padding: EdgeInsets.zero,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              variant != ButtonVariant.outline && variant != ButtonVariant.link
                  ? backgroundColor
                  : Colors.transparent,
          border: variant == ButtonVariant.outline
              ? Border.all(color: foregroundColor)
              : null,
          borderRadius: BorderRadius.circular(8),
          boxShadow: boxShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              CupertinoActivityIndicator(
                color: foregroundColor,
              )
            else ...[
              if (icon != null) ...[
                Icon(icon, color: foregroundColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: AppTextStyles.button.fontSize,
                  fontWeight: AppTextStyles.button.fontWeight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return isDarkMode ? AppColorsDark.primary : AppColors.primary;
      case ButtonVariant.secondary:
        return isDarkMode ? AppColorsDark.secondary : AppColors.secondary;
      case ButtonVariant.muted:
        return isDarkMode ? AppColorsDark.muted : AppColors.muted;
      case ButtonVariant.destructive:
        return isDarkMode ? AppColorsDark.destructive : AppColors.destructive;
      default:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return isDarkMode
            ? AppColorsDark.primaryForeground
            : AppColors.primaryForeground;
      case ButtonVariant.secondary:
        return isDarkMode
            ? AppColorsDark.secondaryForeground
            : AppColors.secondaryForeground;
      case ButtonVariant.outline:
        return isDarkMode ? AppColorsDark.primaryForeground : AppColors.primary;
      case ButtonVariant.muted:
        return isDarkMode
            ? AppColorsDark.mutedForeground
            : AppColors.mutedForeground;
      case ButtonVariant.destructive:
        return isDarkMode
            ? AppColorsDark.destructiveForeground
            : AppColors.destructiveForeground;
      case ButtonVariant.link:
        return isDarkMode ? AppColorsDark.primary : AppColors.primary;
    }
  }

  List<BoxShadow>? _getBoxShadow() {
    if (variant == ButtonVariant.outline || variant == ButtonVariant.link) {
      return null; // No shadow for outline or link variants
    }
    return [
      BoxShadow(
        color: isDarkMode
            ? Colors.black.withOpacity(0.5)
            : Colors.grey.withOpacity(0.3),
        blurRadius: 6,
        offset: const Offset(0, 4), // Downward shadow
      ),
    ];
  }
}
