import 'dart:async';
import 'package:flutter/material.dart';
import 'package:find_your_pet/layout/main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 0.0;
      });
    });

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 3),
          curve: Curves.easeInOut,
          child: Center(
            child: Image.asset(
              'assets/images/poster.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
