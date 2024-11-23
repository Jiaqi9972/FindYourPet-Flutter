// profile_page.dart
import 'package:find_your_pet/api/api_service.dart';
import 'package:find_your_pet/layout/main_tab_screen.dart';
import 'package:find_your_pet/styles/ui/card.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/styles/ui/button.dart';
import 'package:find_your_pet/widgets/profile/loading_overlay.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  String? avatarUrl;
  String? name;
  String? email;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      String? idToken = await user?.getIdToken();
      if (idToken != null) {
        final userData = await ApiService().loginUser(idToken);
        setState(() {
          name = userData['name'];
          email = userData['email'];
          avatarUrl = userData['avatarUrl'];
        });
      }
    } catch (error) {
      print("Error loading profile: $error");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signOut();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
          builder: (context) => const MainTabScreen(initialIndex: 3),
        ),
        (route) => false,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return CupertinoPageScaffold(
      backgroundColor:
          isDarkMode ? AppColorsDark.background : AppColors.background,
      child: AppLoadingOverlay(
        isLoading: _loading,
        isDarkMode: isDarkMode,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                if (user != null) ...[
                  AppCard(
                    isDarkMode: isDarkMode,
                    content: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: isDarkMode
                                ? AppColorsDark.muted
                                : AppColors.muted,
                          ),
                          child: avatarUrl == null
                              ? Icon(CupertinoIcons.person_fill,
                                  size: 50,
                                  color: isDarkMode
                                      ? AppColorsDark.mutedForeground
                                      : AppColors.mutedForeground)
                              : null,
                        ),
                        SizedBox(height: 16),
                        Text(name ?? 'User',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? AppColorsDark.foreground
                                    : AppColors.foreground)),
                        Text(email ?? '',
                            style: TextStyle(
                                color: isDarkMode
                                    ? AppColorsDark.mutedForeground
                                    : AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  AppButton(
                    text: 'Edit Profile',
                    variant: ButtonVariant.outline,
                    isDarkMode: isDarkMode,
                    onPressed: () =>
                        Navigator.pushNamed(context, '/complete_profile'),
                  ),
                  SizedBox(height: 8),
                  AppButton(
                    text: 'Sign Out',
                    variant: ButtonVariant.destructive,
                    isDarkMode: isDarkMode,
                    onPressed: _signOut,
                  ),
                ] else
                  Column(
                    children: [
                      Icon(CupertinoIcons.person_circle,
                          size: 80,
                          color: isDarkMode
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground),
                      SizedBox(height: 16),
                      Text('Sign in to manage your profile',
                          style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode
                                  ? AppColorsDark.foreground
                                  : AppColors.foreground)),
                      SizedBox(height: 24),
                      AppButton(
                        text: 'Sign In',
                        variant: ButtonVariant.primary,
                        isDarkMode: isDarkMode,
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                      ),
                    ],
                  ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Dark Mode',
                        style: TextStyle(
                            color: isDarkMode
                                ? AppColorsDark.foreground
                                : AppColors.foreground)),
                    SizedBox(width: 8),
                    CupertinoSwitch(
                      value: isDarkMode,
                      activeColor: isDarkMode
                          ? AppColorsDark.primary
                          : AppColors.primary,
                      onChanged: (value) =>
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
