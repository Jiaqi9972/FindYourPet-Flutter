import 'package:find_your_pet/layout/main_layout.dart';
import 'package:find_your_pet/pages/complete_profile_page.dart';
import 'package:find_your_pet/pages/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:find_your_pet/pages/login_page.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
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
          theme: themeProvider.getAppTheme(),
          routes: {
            '/login': (context) => LoginPage(),
            '/complete_profile': (context) => CompleteProfilePage(),
            '/main': (context) => const MainLayout(),
            '/profile': (context) => ProfilePage()
          },
          home: const MainLayout(),
        );
      },
    );
  }
}
