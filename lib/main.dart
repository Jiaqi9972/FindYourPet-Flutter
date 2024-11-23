import 'package:find_your_pet/layout/main_tab_screen.dart';
import 'package:find_your_pet/pages/profile/complete_profile_page.dart';
import 'package:find_your_pet/pages/profile/login.dart';
import 'package:find_your_pet/pages/profile/register.dart';
import 'package:find_your_pet/pages/splush/splush.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:find_your_pet/provider/pet_status_provider.dart';
import 'package:find_your_pet/provider/view_provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ViewModeProvider()),
        ChangeNotifierProvider(create: (_) => PetStatusProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return CupertinoApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
          ],
          routes: {
            '/': (context) => const SplashScreen(),
            '/main': (context) => const MainTabScreen(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/complete_profile': (context) => const CompleteProfilePage(),
          },
          builder: (context, child) {
            // Wrap all pages with error handling
            return CupertinoPageScaffold(
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
