import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
// import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID', null);
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
