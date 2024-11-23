import 'package:find_your_pet/pages/add/add_page.dart';
import 'package:find_your_pet/pages/find/find_page.dart';
import 'package:find_your_pet/pages/message_page.dart';
import 'package:find_your_pet/pages/profile/profile_page.dart';
import 'package:find_your_pet/styles/color/app_colors_config.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class MainTabScreen extends StatefulWidget {
  final int initialIndex;

  const MainTabScreen({super.key, this.initialIndex = 0});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const FindPage(),
    const AddPage(),
    const MessagePage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: colors.background,
        activeColor: isDarkMode ? colors.mutedForeground : colors.primary,
        inactiveColor: isDarkMode ? colors.primary : colors.mutedForeground,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.paw), label: 'Find'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.add_circled_solid), label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble), label: 'Message'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person), label: 'Profile'),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        return _pages[index];
      },
    );
  }
}
