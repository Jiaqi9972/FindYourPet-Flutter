import 'package:find_your_pet/layout/main_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_your_pet/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _errorMessage;
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        String? idToken = await user.getIdToken();

        if (idToken != null) {
          // use backend API
          final loginResponse = await _apiService.getUserProfile(idToken);
          final profileComplete = loginResponse['profileComplete'] ?? false;

          // keep login timestamp and idToken
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt(
              'login_timestamp', DateTime.now().millisecondsSinceEpoch);
          await prefs.setString('idToken', idToken); // save idToken

          if (profileComplete) {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (context) => const MainLayout(currentIndex: 3),
              ),
            );
          } else {
            Navigator.of(context).pushReplacementNamed('/complete_profile');
          }
        } else {
          setState(() {
            _errorMessage = "Failed to retrieve ID Token.";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to log in user.";
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login Page'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!,
                    style: const TextStyle(color: CupertinoColors.systemRed)),
              CupertinoTextFormFieldRow(
                controller: _emailController,
                placeholder: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              CupertinoTextFormFieldRow(
                controller: _passwordController,
                placeholder: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_loading) const CupertinoActivityIndicator(),
              if (!_loading)
                CupertinoButton.filled(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
