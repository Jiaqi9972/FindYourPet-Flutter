import 'package:find_your_pet/layout/main_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:find_your_pet/api/api_service.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  _CompleteProfilePageState createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  final ApiService _apiService = ApiService();

  Future<void> _submitProfile() async {
    String username = _usernameController.text.trim();
    String avatarUrl = _avatarUrlController.text.trim();

    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      print('ID Token: $idToken');
      if (idToken != null) {
        await _apiService.updateUserProfile(username, avatarUrl, idToken);
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const MainLayout(currentIndex: 3),
          ),
        );
      } else {
        // if there is no idToken, ask user to login
        print("Failed to retrieve ID Token. Please log in again.");
        // TODO: redirect to login page
      }
    } catch (error) {
      print("Error submitting profile: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Complete Profile'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoTextFormFieldRow(
              controller: _usernameController,
              placeholder: 'Username',
            ),
            const SizedBox(height: 20),
            CupertinoTextFormFieldRow(
              controller: _avatarUrlController,
              placeholder: 'Avatar URL',
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: _submitProfile,
              child: const Text('Submit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
