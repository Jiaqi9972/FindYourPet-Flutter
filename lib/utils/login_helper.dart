import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:find_your_pet/api/api_service.dart';
import 'package:find_your_pet/layout/main_tab_screen.dart';
import 'package:flutter/cupertino.dart';

class LoginHelper {
  static final _auth = FirebaseAuth.instance;
  static final _apiService = ApiService();

  static Future<void> handleAuthSuccess(BuildContext context, User user) async {
    try {
      String? idToken = await user.getIdToken();
      if (idToken != null) {
        final loginResponse = await _apiService.loginUser(idToken);
        final profileComplete = loginResponse['isProfileComplete'] ?? false;
        final name = loginResponse['name'];
        final avatarUrl = loginResponse['avatarUrl'];

        final isProfileComplete = name != null &&
            name.isNotEmpty &&
            avatarUrl != null &&
            avatarUrl.isNotEmpty;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
            'login_timestamp', DateTime.now().millisecondsSinceEpoch);
        await prefs.setString('idToken', idToken);

        if (isProfileComplete) {
          Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(
              builder: (context) => const MainTabScreen(initialIndex: 3),
            ),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushReplacementNamed('/complete_profile');
        }
      }
    } catch (error) {
      throw error;
    }
  }

  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          await handleAuthSuccess(context, userCredential.user!);
        }
      }
    } catch (error) {
      throw error;
    }
  }
}
