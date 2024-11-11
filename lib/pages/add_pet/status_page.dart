import 'package:find_your_pet/provider/theme_provider.dart';
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
    final theme = context.watch<ThemeProvider>();
    final appTheme = theme.getAppTheme();

    return CupertinoPageScaffold(
      backgroundColor: appTheme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Lost or Found?',
                style: appTheme.textTheme.textStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              CupertinoButton(
                color: appTheme.primaryColor,
                child: Text(
                  'I Lost a Pet',
                  style: TextStyle(
                    color: appTheme.primaryContrastingColor,
                  ),
                ),
                onPressed: () => onStatusSelected(true),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                color: appTheme.primaryColor,
                child: Text(
                  'I Found a Pet',
                  style: TextStyle(
                    color: appTheme.primaryContrastingColor,
                  ),
                ),
                onPressed: () => onStatusSelected(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
