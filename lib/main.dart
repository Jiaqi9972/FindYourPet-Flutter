import 'package:find_your_pet/firebase_options.dart';
import 'package:find_your_pet/layout/main_layout.dart';
import 'package:find_your_pet/pages/profile/complete_profile_page.dart';
import 'package:find_your_pet/pages/profile/profile_page.dart';
import 'package:find_your_pet/provider/location_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:find_your_pet/pages/profile/login_page.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Firebase initialized');
  print('Storage bucket: ${FirebaseStorage.instance.bucket}');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
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
          theme: themeProvider.getAppTheme(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/complete_profile': (context) => const CompleteProfilePage(),
            '/main': (context) => const MainLayout(),
            '/profile': (context) => const ProfilePage()
          },
          home: const MainLayout(),
        );
      },
    );
  }
}
