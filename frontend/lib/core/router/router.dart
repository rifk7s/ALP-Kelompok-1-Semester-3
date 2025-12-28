import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/router/guards/auth_guard.dart';
import 'package:frontend/core/router/routes/auth_routes.dart';
import 'package:frontend/core/auth/bloc/auth_bloc.dart';
import 'package:frontend/features/pembeli/screens/product_detail_screen.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/cart_screen.dart';
import 'package:frontend/features/bumdes/screens/upload_screen.dart';
import 'package:frontend/features/bumdes/screens/edit_product_screen.dart';
import 'package:frontend/features/bumdes/screens/petani/add_screen.dart';
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
    GoRoute(
      path: RoutePaths.pembeliHome,
      name: RouteNames.pembeliHome,
      builder: (context, state) => const _PembeliNavigationWrapper(),
      routes: [
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
        GoRoute(
          path: RoutePaths.notifications,
          name: RouteNames.notifications,
          builder: (context, state) => const NotificationPage(),
        ),
        GoRoute(
          path: RoutePaths.cart,
          name: RouteNames.cart,
          builder: (context, state) => const CartPage(),
        ),
      ],
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
          builder: (context, state) =>
              Placeholder(), // TODO: Import PetaniDetailScreen
        ),
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
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Halaman tidak ditemukan', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            state.uri.toString(),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(RoutePaths.splash),
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

/// Navigation wrapper for Pembeli (Buyer) - maintains bottom navigation
class _PembeliNavigationWrapper extends StatelessWidget {
  const _PembeliNavigationWrapper();

  @override
  Widget build(BuildContext context) {
    // This will be replaced by the actual StartPage with bottom nav
    return const Placeholder();
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
