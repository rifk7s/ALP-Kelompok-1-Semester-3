import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/router/guards/auth_guard.dart';
import 'package:frontend/core/router/routes/auth_routes.dart';
import 'package:frontend/core/router/routes/pembeli_routes.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/auth/bloc/auth_bloc.dart';
import 'package:frontend/features/pembeli/screens/product_detail_screen.dart';
import 'package:frontend/features/pembeli/screens/search_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/cart_screen.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'package:frontend/features/pembeli/screens/profile_screen.dart';
import 'package:frontend/features/pembeli/screens/edit_profile_screen.dart';
import 'package:frontend/features/shared/screens/setting_screen.dart';
import 'package:frontend/features/shared/screens/help_screen.dart';
import 'package:frontend/features/shared/screens/about_screen.dart';
import 'package:frontend/features/shared/screens/hpp_screen.dart';
import 'package:frontend/features/bumdes/screens/upload_screen.dart';
import 'package:frontend/features/bumdes/screens/edit_product_screen.dart';
import 'package:frontend/features/bumdes/screens/petani/add_screen.dart';
import 'package:frontend/features/bumdes/screens/petani/detail_screen.dart';
import 'package:frontend/features/shared/screens/chat_detail_page.dart';

/// Main GoRouter configuration with Bloc integration
final router = GoRouter(
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: true,
  redirect: (BuildContext context, GoRouterState state) {
    final authStatus = context.read<AuthBloc>().state.status;
    return RouteGuards.requireAuth(context, state, authStatus);
  },
  refreshListenable: _AuthListenable(),
  routes: [
    // Auth routes (splash, login, register, start)
    ...AuthRoutes.routes,

    // Pembeli routes with ShellRoute for bottom navigation
    PembeliRoutes.pembeliShellRoute,

    // Additional pembeli routes (outside shell - full screen)
    GoRoute(
      path: RoutePaths.search,
      name: RouteNames.search,
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: RoutePaths.hpp,
      name: RouteNames.hpp,
      builder: (context, state) => const HppPage(),
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

    // Product detail route (outside shell - full screen)
    GoRoute(
      path: RoutePaths.productDetail,
      name: RouteNames.productDetail,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final id = state.pathParameters['id'];
        final productMap =
            extra ?? (id != null ? {'id': int.tryParse(id)} : {});
        return ProductDetailPage(product: productMap);
      },
    ),

    // Chat route (accessible from anywhere)
    GoRoute(
      path: RoutePaths.chat,
      name: RouteNames.chat,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final id = state.pathParameters['id'] ?? '';
        final chatId = extra != null && extra['chatId'] != null
            ? extra['chatId'] as String
            : id;
        final name = extra != null && extra['name'] != null
            ? extra['name'] as String
            : '';
        final image = extra != null && extra['image'] != null
            ? extra['image'] as String
            : 'assets/images/logo.png';
        final recipientId = extra != null && extra['recipientId'] != null
            ? extra['recipientId'] as String
            : '';
        return ChatDetailPage(
          chatId: chatId,
          name: name,
          image: image,
          recipientId: recipientId,
        );
      },
    ),

    // Bumdes routes
    GoRoute(
      path: RoutePaths.bumdesHome,
      name: RouteNames.bumdesHome,
      builder: (context, state) => const _BumdesNavigationWrapper(),
      routes: [
        GoRoute(
          path: RoutePaths.productUpload,
          name: RouteNames.productUpload,
          builder: (context, state) => const UploadProdukScreen(),
        ),
        GoRoute(
          path: RoutePaths.productEdit,
          name: RouteNames.productEdit,
          builder: (context, state) {
            final product = state.extra as Map<String, dynamic>?;
            return EditProdukScreen(product: product ?? {});
          },
        ),
        GoRoute(
          path: RoutePaths.petaniAdd,
          name: RouteNames.petaniAdd,
          builder: (context, state) => const TambahPetaniScreen(),
        ),
        GoRoute(
          path: RoutePaths.petaniDetail,
          name: RouteNames.petaniDetail,
          builder: (context, state) {
            final idStr = state.pathParameters['id'] ?? '';
            final petaniId = int.tryParse(idStr) ?? 0;
            return PetaniDetailScreen(petaniId: petaniId);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: 16),
          const Text('Halaman tidak ditemukan', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            state.uri.toString(),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(RoutePaths.pembeliHome),
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    ),
  ),
);

/// Custom Listenable to trigger router refresh when auth state changes
class _AuthListenable extends ChangeNotifier {
  @override
  void dispose() {
    // Don't dispose - this will be managed by GoRouter
    super.dispose();
  }
}

/// Navigation wrapper for Bumdes - maintains bottom navigation
class _BumdesNavigationWrapper extends StatelessWidget {
  const _BumdesNavigationWrapper();

  @override
  Widget build(BuildContext context) {
    // This will be replaced by the actual StartPageBumdes with bottom nav
    return const Placeholder();
  }
}
