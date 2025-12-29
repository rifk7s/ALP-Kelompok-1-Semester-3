import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/router.dart';
import 'package:frontend/core/auth/bloc/auth_bloc.dart';
import 'package:frontend/features/pembeli/bloc/cart/cart_bloc.dart';
import 'package:frontend/features/pembeli/bloc/product_detail/product_detail_bloc.dart';
import 'package:frontend/features/pembeli/bloc/home/home_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()..add(AuthStarted())),
        BlocProvider(create: (context) => CartBloc()),
        BlocProvider(create: (context) => ProductDetailBloc()),
        BlocProvider(create: (context) => HomeBloc()),
        // Add other BLoCs here as needed
      ],
      child: MaterialApp.router(
        title: 'PanenKi\'',
        theme: AppTheme.theme,
        routerConfig: router,
      ),
    );
  }
}
