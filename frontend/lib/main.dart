import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
// import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PanenKi',
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
