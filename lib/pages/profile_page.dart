import 'package:find_your_pet/layout/main_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/utils/color.dart';
import 'package:find_your_pet/utils/color_dark.dart';
import 'package:find_your_pet/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  String? avatarUrl;
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    _checkLoginExpiry(); // check if login expire
    _loadUserProfile(); // get userinfo from api
  }

  Future<void> _checkLoginExpiry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? loginTimestamp = prefs.getInt('login_timestamp');
    if (loginTimestamp != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int daysDifference =
          (currentTime - loginTimestamp) ~/ (1000 * 60 * 60 * 24);

      if (daysDifference >= 30) {
        // if exceed 30 days, log out
        await _signOut();
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      // get Firebase ID Token
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      if (idToken != null) {
        // get user info from firebase api and send token
        final userData = await ApiService().loginUser(idToken);

        setState(() {
          name = userData['name'];
          email = userData['email'];
          avatarUrl = userData['avatarUrl'];
          _loading = false;
        });
      } else {
        print("Failed to retrieve ID Token");
        setState(() {
          _loading = false;
        });
      }
    } catch (error) {
      print("Error loading user profile: $error");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      // use signOut from firebase
      await FirebaseAuth.instance.signOut();

      // clear user info
      setState(() {
        name = null;
        email = null;
        avatarUrl = null;
      });

      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => const MainLayout(currentIndex: 3),
        ),
      );
    } catch (error) {
      print("Error during sign out: $error");
    }
  }

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final backgroundColor = themeProvider.isDarkMode
        ? AppColorsDark.background
        : AppColors.background;

    final textStyle = TextStyle(
      color: themeProvider.isDarkMode
          ? AppColorsDark.foreground
          : AppColors.foreground,
      fontSize: 16,
    );

    final buttonColor =
        themeProvider.isDarkMode ? AppColorsDark.primary : AppColors.primary;

    final buttonTextColor = themeProvider.isDarkMode
        ? AppColorsDark.primaryForeground
        : AppColors.primaryForeground;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _loading
              ? const Center(child: CupertinoActivityIndicator())
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      user != null
                          ? Column(
                              children: [
                                Text('Welcome, $name', style: textStyle),
                                const SizedBox(height: 20),
                                Text('Email: $email', style: textStyle),
                                const SizedBox(height: 20),
                                CupertinoButton(
                                  color: buttonColor,
                                  child: Text(
                                    'print token',
                                    style: TextStyle(color: buttonTextColor),
                                  ),
                                  onPressed: () async {
                                    String? token = await user?.getIdToken();
                                    print(
                                        token); // Print the token when the button is pressed
                                  },
                                ),
                              ],
                            )
                          : Text('Please login to get more', style: textStyle),
                      const SizedBox(height: 20),
                      CupertinoSwitch(
                        value: themeProvider.isDarkMode,
                        onChanged: (bool value) {
                          themeProvider.toggleTheme();
                        },
                      ),
                      const SizedBox(height: 20),
                      CupertinoButton(
                        color: buttonColor,
                        onPressed: themeProvider.toggleTheme,
                        child: Text(
                          themeProvider.isDarkMode
                              ? 'Switch to Light Mode'
                              : 'Switch to Dark Mode',
                          style: TextStyle(color: buttonTextColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      user != null
                          ? CupertinoButton(
                              color: themeProvider.isDarkMode
                                  ? AppColorsDark.destructive
                                  : AppColors.destructive,
                              onPressed: _signOut,
                              child: Text(
                                'Sign Out',
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? AppColorsDark.destructiveForeground
                                      : AppColors.destructiveForeground,
                                ),
                              ),
                            )
                          : CupertinoButton.filled(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pushReplacementNamed('/login');
                              },
                              child: const Text('Go to Login Page'),
                            ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
