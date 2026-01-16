import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lms_pro/screen/homescreen.dart';
import 'package:lms_pro/screen/splashscreen.dart';
import 'package:lms_pro/singin/login.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool("dark_mode") ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark_mode", isDark);
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Student LMS',
          themeMode: mode,

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8F7FF),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF9B5DE5),
              brightness: Brightness.light,
            ),
            cardColor: Colors.white,
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F0A19),
            cardColor: const Color(0xFF191326),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFB983FF),
              secondary: Color(0xFF9B5DE5),
              background: Color(0xFF0F0A19),
            ),
            useMaterial3: true,
          ),

          routes: {
            '/onboarding': (context) => OnboardingScreen(),
            '/login': (context) => LoginPage(),
            '/student-dashboard': (context) => const HomePage(),
          },

          home: SplashScreen(),
        );
      },
    );
  }
}
