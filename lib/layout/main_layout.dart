import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/utils/color.dart';
import 'package:find_your_pet/utils/color_dark.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/pages/find_page.dart';
import 'package:find_your_pet/pages/add_pet/add_page.dart';
import 'package:find_your_pet/pages/message_page.dart';
import 'package:find_your_pet/pages/profile_page.dart';

class MainLayout extends StatefulWidget {
  final int currentIndex;

  const MainLayout({super.key, this.currentIndex = 0});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late CupertinoTabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController(initialIndex: widget.currentIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        activeColor: themeProvider.isDarkMode
            ? AppColorsDark.primary
            : AppColors.primary,
        backgroundColor:
            themeProvider.isDarkMode ? AppColorsDark.card : AppColors.card,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search), label: 'Find'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.add_circled_solid), label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble), label: 'Message'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person), label: 'Profile'),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoPageScaffold(
          backgroundColor: themeProvider.isDarkMode
              ? AppColorsDark.background
              : AppColors.background,
          child: _buildPage(index),
        );
      },
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const FindPage();
      case 1:
        return const AddPage();
      case 2:
        return const MessagePage();
      case 3:
        return ProfilePage();
      default:
        return const FindPage();
    }
  }
}
