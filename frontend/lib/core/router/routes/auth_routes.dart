import 'package:go_router/go_router.dart';
import 'package:frontend/splash_screen.dart';
import 'package:frontend/features/auth/view/screens/auth_screen.dart';
import 'package:frontend/features/pembeli/view/screens/start_page.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/utils/page_transitions.dart';

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
          FadeTransitionPage(child: const AuthScreen(initialIsLogin: true)),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: const AuthScreen(initialIsLogin: true)),
    ),
    GoRoute(
      path: RoutePaths.register,
      name: RouteNames.register,
      pageBuilder: (context, state) =>
          FadeTransitionPage(child: const AuthScreen(initialIsLogin: false)),
    ),
  ];
}
