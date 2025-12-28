import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/pembeli/screens/home_screen.dart';
import 'package:frontend/features/pembeli/screens/search_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/cart_screen.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'package:frontend/features/pembeli/screens/profile_screen.dart';
import 'package:frontend/features/pembeli/screens/edit_profile_screen.dart';
import 'package:frontend/features/shared/screens/setting_screen.dart';
import 'package:frontend/features/shared/screens/help_screen.dart';
import 'package:frontend/features/shared/screens/about_screen.dart';
import 'package:frontend/core/router/route_constants.dart';

/// Pembeli (Buyer) feature routes using ShellRoute for bottom navigation
class PembeliRoutes {
  static RouteBase pembeliShellRoute = ShellRoute(
    builder: (context, state, child) {
      return _PembeliShell(child: child);
    },
    routes: [
      GoRoute(
        path: RoutePaths.pembeliHome,
        name: RouteNames.pembeliHome,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: RoutePaths.cart,
        name: RouteNames.cart,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: RoutePaths.help,
        name: RouteNames.help,
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: RoutePaths.about,
        name: RouteNames.about,
        builder: (context, state) => const AboutAppPage(),
      ),
    ],
  );
}

/// Shell widget for pembeli navigation
class _PembeliShell extends StatelessWidget {
  final Widget child;

  const _PembeliShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
