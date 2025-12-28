import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/auth/bloc/auth_bloc.dart';

/// Guards for protected routes
class RouteGuards {
  /// Redirects unauthenticated users to login
  static String? requireAuth(
    BuildContext context,
    GoRouterState state,
    AuthStatus authStatus,
  ) {
    final isAuthenticated = authStatus == AuthStatus.authenticated;
    final isAuthRoute =
        state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/register') ||
        state.matchedLocation.startsWith('/auth') ||
        state.matchedLocation == '/start' ||
        state.matchedLocation == '/';

    if (!isAuthenticated && !isAuthRoute) {
      // Store the intended location for redirect after login
      return RoutePaths.login;
    }

    if (isAuthenticated && isAuthRoute && state.matchedLocation != '/') {
      // Redirect authenticated users away from auth pages
      final user = context.read<AuthBloc>().state.user;
      final role = user?['role'] as String?;

      if (role == 'bumdes') {
        return RoutePaths.bumdesHome;
      } else {
        return RoutePaths.pembeliHome;
      }
    }

    return null; // No redirect needed
  }

  /// Redirects users based on role
  static String? requireRole(
    BuildContext context,
    GoRouterState state,
    String? currentRole,
    List<String> allowedRoles,
  ) {
    if (currentRole == null) {
      return RoutePaths.login;
    }

    if (!allowedRoles.contains(currentRole)) {
      // Redirect to appropriate home based on role
      if (currentRole == 'bumdes') {
        return RoutePaths.bumdesHome;
      } else {
        return RoutePaths.pembeliHome;
      }
    }

    return null;
  }
}
