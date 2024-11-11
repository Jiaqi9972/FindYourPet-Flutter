import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ImagePage extends StatefulWidget {
  final List<String> petImageUrls;
  final ValueChanged<List<String>> onImageUrlsEntered;
  final VoidCallback onBack;

  const ImagePage({
    Key? key,
    required this.petImageUrls,
    required this.onImageUrlsEntered,
    required this.onBack,
  }) : super(key: key);

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.petImageUrls.join(', '));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleNext() {
    List<String> urls = _controller.text
        .split(',')
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
    widget.onImageUrlsEntered(urls);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final textStyle = theme.getAppTheme().textTheme.textStyle;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Add Pet Images',
          style: textStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        CupertinoTextField(
          controller: _controller,
          placeholder: 'Pet Image URLs (comma-separated)',
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? CupertinoColors.systemGrey6.darkColor
                : CupertinoColors.systemGrey6.color,
            borderRadius: BorderRadius.circular(8),
          ),
          style: textStyle,
          placeholderStyle: textStyle.copyWith(
            color: theme.isDarkMode
                ? CupertinoColors.systemGrey.darkColor
                : CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CupertinoButton(
              color: theme.getAppTheme().primaryColor.withOpacity(0.8),
              onPressed: widget.onBack,
              child: const Text('Back'),
            ),
            CupertinoButton(
              color: theme.getAppTheme().primaryColor,
              onPressed: _handleNext,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}
