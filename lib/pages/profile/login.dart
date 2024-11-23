import 'package:find_your_pet/utils/login_helper.dart';
import 'package:find_your_pet/widgets/profile/divider_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/styles/ui/button.dart';
import 'package:find_your_pet/styles/ui/input.dart';
import 'package:find_your_pet/widgets/profile/loading_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String? _errorMessage;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // ignore: use_build_context_synchronously
        await LoginHelper.handleAuthSuccess(context, userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
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
        middle: const Text('Login'),
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
                  const SizedBox(height: 16),
                  AppTextInput(
                    controller: _emailController,
                    placeholder: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    isDarkMode: isDarkMode,
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Please enter your email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextInput(
                    controller: _passwordController,
                    placeholder: 'Password',
                    obscureText: true,
                    isDarkMode: isDarkMode,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your password';
                      }
                      if (value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Login',
                    variant: ButtonVariant.primary,
                    isDarkMode: isDarkMode,
                    onPressed: _login,
                    isLoading: _loading,
                  ),
                  const SizedBox(height: 16),
                  DividerText(
                    text: 'or',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Sign in with Google',
                    variant: ButtonVariant.outline,
                    isDarkMode: isDarkMode,
                    icon: CupertinoIcons.globe,
                    onPressed: () => LoginHelper.signInWithGoogle(context),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: Text(
                      'New user? Create an account',
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColorsDark.foreground
                            : AppColors.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
