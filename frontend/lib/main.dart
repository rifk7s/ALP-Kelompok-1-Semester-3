import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/router.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID', null);

  // Setup dependency injection
  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Initialize AuthBloc on app start
    sl<AuthBloc>().add(AuthStarted());
    // Create router with AuthBloc for reactive auth changes
    _router = createRouter(sl<AuthBloc>());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only provide AuthBloc at root level
    // Scoped BLoCs (Cart, Home, ProductDetail) are provided in authenticated routes
    return BlocProvider.value(
      value: sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == AuthStatus.unauthenticated,
        listener: (context, state) {
          // Scope cleanup is handled by AuthBloc.popAuthenticatedScope()
          // Just navigate to login
          _router.go(RoutePaths.login);
        },
        child: MaterialApp.router(
          title: 'PanenKi\'',
          theme: AppTheme.theme,
          routerConfig: _router,
        ),
      ),
    );
  }
}
