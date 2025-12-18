import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lms_pro/screen/homescreen.dart';
import 'package:lms_pro/screen/splashscreen.dart';
import 'package:lms_pro/singin/login.dart';

// GLOBAL THEME NOTIFIER
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved theme
  final prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool("dark_mode") ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // GLOBAL THEME SETTER
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

          // LIGHT THEME
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Color(0xFFF8F7FF),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF9B5DE5),
              brightness: Brightness.light,
            ),
            cardColor: Colors.white,
            useMaterial3: true,
          ),

          // DARK THEME
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Color(0xFF0F0A19),
            cardColor: Color(0xFF191326),
            colorScheme: ColorScheme.dark(
              primary: Color(0xFFB983FF),
              secondary: Color(0xFF9B5DE5),
              background: Color(0xFF0F0A19),
            ),
            useMaterial3: true,
          ),

          routes: {
            '/login': (context) => LoginPage(),
            '/student-dashboard': (context) => const HomePage(),
          },

          home: SplashScreen(),
        );
      },
    );
  }
}
