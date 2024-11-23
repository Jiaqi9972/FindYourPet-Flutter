import 'package:flutter/cupertino.dart';
import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:find_your_pet/styles/font/text_styles.dart';

class AppTextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isDarkMode;

  const AppTextInput({
    super.key,
    this.controller,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDarkMode ? AppColorsDark.foreground : AppColors.foreground,
        fontSize: AppTextStyles.input.fontSize,
        fontWeight: AppTextStyles.input.fontWeight,
      ),
      placeholderStyle: TextStyle(
        color: isDarkMode
            ? AppColorsDark.mutedForeground
            : AppColors.mutedForeground,
        fontSize: AppTextStyles.input.fontSize,
        fontWeight: AppTextStyles.input.fontWeight,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.input : AppColors.input,
        border: Border.all(
            color: isDarkMode ? AppColorsDark.border : AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
