import 'package:flutter/cupertino.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Message Page',
            style: CupertinoTheme.of(context).textTheme.textStyle,
          ),
        ),
      ),
    );
  }
}
