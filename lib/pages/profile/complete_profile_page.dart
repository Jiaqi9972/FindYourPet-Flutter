import 'package:find_your_pet/api/api_service.dart';
import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/styles/ui/button.dart';
import 'package:find_your_pet/styles/ui/input.dart';
import 'package:find_your_pet/widgets/profile/loading_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CompleteProfilePageState createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _apiService = ApiService();
  String? _errorMessage;
  bool _loading = false;

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null) {
        await _apiService.updateUserProfile(
          _usernameController.text.trim(),
          _avatarUrlController.text.trim(),
          idToken,
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (error) {
      setState(() => _errorMessage = error.toString());
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Complete Profile'),
        backgroundColor:
            isDarkMode ? AppColorsDark.background : AppColors.background,
      ),
      child: AppLoadingOverlay(
        isLoading: _loading,
        isDarkMode: isDarkMode,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColorsDark.destructive
                            : AppColors.destructive,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  AppTextInput(
                    controller: _usernameController,
                    placeholder: 'Username',
                    isDarkMode: isDarkMode,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter a username'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextInput(
                    controller: _avatarUrlController,
                    placeholder: 'Avatar URL',
                    isDarkMode: isDarkMode,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter an avatar URL';
                      }
                      final uri = Uri.tryParse(value!);
                      if (uri == null || !uri.isAbsolute) {
                        return 'Please enter a valid URL';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Complete Profile',
                    variant: ButtonVariant.primary,
                    isDarkMode: isDarkMode,
                    onPressed: _submitProfile,
                    isLoading: _loading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
