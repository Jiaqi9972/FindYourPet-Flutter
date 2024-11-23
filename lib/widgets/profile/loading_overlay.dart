import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:flutter/cupertino.dart';

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final bool isDarkMode;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color:
                (isDarkMode ? AppColorsDark.background : AppColors.background)
                    .withOpacity(0.7),
            child: Center(
              child: CupertinoActivityIndicator(
                color: isDarkMode ? AppColorsDark.primary : AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
