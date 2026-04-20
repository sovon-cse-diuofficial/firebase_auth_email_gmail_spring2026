import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LostFoundCampusApp());
}

class LostFoundCampusApp extends StatefulWidget {
  const LostFoundCampusApp({super.key});

  static _LostFoundCampusAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_LostFoundCampusAppState>();
  }

  @override
  State<LostFoundCampusApp> createState() => _LostFoundCampusAppState();
}

class _LostFoundCampusAppState extends State<LostFoundCampusApp> {
  bool _isDarkMode = false;

  void toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  bool get isDarkMode => _isDarkMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost & Found Campus',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}