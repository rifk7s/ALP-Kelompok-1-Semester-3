import 'package:go_router/go_router.dart';
import 'package:frontend/splash_screen.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';
import 'package:frontend/features/pembeli/screens/start_page.dart';
import 'package:frontend/core/router/route_constants.dart';

/// Auth feature routes
class AuthRoutes {
  static List<RouteBase> routes = [
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.start,
      name: RouteNames.start,
      builder: (context, state) => const StartPage(),
    ),
    GoRoute(
      path: RoutePaths.auth,
      name: RouteNames.auth,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: AuthScreen(initialIsLogin: true)),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: AuthScreen(initialIsLogin: true)),
    ),
    GoRoute(
      path: RoutePaths.register,
      name: RouteNames.register,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: AuthScreen(initialIsLogin: false)),
    ),
  ];
}
