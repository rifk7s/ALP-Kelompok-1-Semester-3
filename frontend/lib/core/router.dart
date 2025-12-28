import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:frontend/splash_screen.dart';
import 'package:frontend/features/auth/screens/auth_screen.dart';

import 'package:frontend/features/pembeli/screens/home_screen.dart';
import 'package:frontend/features/pembeli/screens/product_detail_screen.dart';
import 'package:frontend/features/pembeli/screens/start_page.dart';
import 'package:frontend/features/bumdes/screens/start_page_bumdes.dart';
import 'package:frontend/features/bumdes/screens/product_detail_screen.dart'
    as bumdes;
import 'package:frontend/features/pembeli/screens/transaction/cart_screen.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'package:frontend/features/bumdes/screens/upload_screen.dart';
import 'package:frontend/features/bumdes/screens/edit_product_screen.dart';
import 'package:frontend/features/bumdes/screens/petani/add_screen.dart';
import 'package:frontend/features/bumdes/screens/petani/detail_screen.dart';
import 'package:frontend/features/shared/screens/chat_detail_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: 'splash',
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: 'start',
      path: '/start',
      builder: (context, state) => const StartPage(),
    ),
    GoRoute(
      name: 'start_bumdes',
      path: '/start/bumdes',
      builder: (context, state) => const StartPageBumdes(),
    ),
    GoRoute(
      name: 'register',
      path: '/register',
      pageBuilder: (context, state) =>
          NoTransitionPage(child: const AuthScreen(initialIsLogin: false)),
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      pageBuilder: (context, state) =>
          NoTransitionPage(child: const AuthScreen(initialIsLogin: true)),
    ),
    // Combined auth screen (animated login/register)
    GoRoute(
      name: 'auth',
      path: '/auth',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final initialIsLogin = extra == null || extra['isLogin'] == null
            ? true
            : (extra['isLogin'] as bool);
        return NoTransitionPage(
          child: AuthScreen(initialIsLogin: initialIsLogin),
        );
      },
    ),
    GoRoute(
      name: 'home',
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: 'cart',
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      name: 'notifications',
      path: '/notifications',
      builder: (context, state) => const NotificationPage(),
    ),
    GoRoute(
      name: 'upload',
      path: '/product/upload',
      builder: (context, state) => const UploadProdukScreen(),
    ),
    // Ensure edit route is matched before the generic product/:id route
    GoRoute(
      name: 'edit_product',
      path: '/product/edit/:id',
      builder: (context, state) {
        // product data can be passed via `extra`
        final product = state.extra as Map<String, dynamic>?;
        return EditProdukScreen(product: product ?? {});
      },
    ),
    GoRoute(
      name: 'product_detail',
      path: '/product/:id',
      builder: (context, state) {
        // Build product map from extra or path param
        final extra = state.extra as Map<String, dynamic>?;
        final id = state.pathParameters['id'];
        final productMap =
            extra ?? (id != null ? {'id': int.tryParse(id)} : {});

        // Decide which detail page to show based on stored user role (role-based routing)
        // We use FutureBuilder to resolve stored user asynchronously without blocking the router.
        return FutureBuilder<Map<String, dynamic>?>(
          future: StorageService.getUser(),
          builder: (context, snapshot) {
            final role = snapshot.data != null
                ? snapshot.data!['role'] as String?
                : null;

            if (role == 'bumdes') {
              return bumdes.ProductDetailPage(
                product: productMap,
                onUpdate: (_) {},
              );
            }

            // Default to pembeli detail for other roles or unauthenticated sessions
            return ProductDetailPage(product: productMap);
          },
        );
      },
    ),
    // Petani routes
    GoRoute(
      name: 'petani_add',
      path: '/petani/add',
      builder: (context, state) => const TambahPetaniScreen(),
    ),
    GoRoute(
      name: 'petani_detail',
      path: '/petani/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '';
        final petaniId = int.tryParse(idStr) ?? 0;
        return PetaniDetailScreen(petaniId: petaniId);
      },
    ),
    GoRoute(
      name: 'chat',
      path: '/chat/:id',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final id = state.pathParameters['id'] ?? '';
        final chatId = extra != null && extra['chatId'] != null
            ? extra['chatId'] as String
            : id;
        final name = extra != null && extra['name'] != null
            ? extra['name'] as String
            : (extra?['name'] ?? '');
        final image = extra != null && extra['image'] != null
            ? extra['image'] as String
            : (extra?['image'] ?? 'assets/images/logo.png');
        final recipientId = extra != null && extra['recipientId'] != null
            ? extra['recipientId'] as String
            : (extra?['recipientId'] ?? '');
        return ChatDetailPage(
          chatId: chatId,
          name: name,
          image: image,
          recipientId: recipientId,
        );
      },
    ),
  ],
);
