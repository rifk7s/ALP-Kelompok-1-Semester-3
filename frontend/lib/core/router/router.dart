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
import 'package:frontend/features/pembeli/screens/transaction/transaction_history_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/checkout_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/waiting_payment_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/payment_confirmed_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/payment_rejected_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/receipt_screen.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'package:frontend/features/pembeli/screens/profile_screen.dart';
import 'package:frontend/features/pembeli/screens/edit_profile_screen.dart';
import 'package:frontend/features/shared/screens/setting_screen.dart';
import 'package:frontend/features/shared/screens/help_screen.dart';
import 'package:frontend/features/shared/screens/about_screen.dart';
import 'package:frontend/features/shared/screens/hpp_screen.dart';
import 'package:frontend/features/shared/screens/chat_detail_page.dart';
import 'package:frontend/features/pembeli/screens/transaction/order_track_screen.dart';
import 'package:frontend/features/bumdes/screens/product_detail_screen.dart' as bumdes;
import 'package:frontend/core/router/routes/bumdes_routes.dart';
import 'package:frontend/core/utils/page_transitions.dart';

/// Main GoRouter configuration with Bloc integration
/// Creates router with AuthBloc stream for reactive auth changes
GoRouter createRouter(AuthBloc authBloc) => GoRouter(
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: true,
  redirect: (BuildContext context, GoRouterState state) {
    final authStatus = authBloc.state.status;
    
    // While auth is still loading (unknown), don't redirect from splash
    if (authStatus == AuthStatus.unknown && state.matchedLocation == '/') {
      return null;
    }
    
    return RouteGuards.requireAuth(context, state, authStatus);
  },
  refreshListenable: GoRouterRefreshStream(authBloc.stream),
  routes: [
    // Auth routes (splash, login, register, start)
    ...AuthRoutes.routes,

    // Pembeli routes with ShellRoute for bottom navigation
    PembeliRoutes.pembeliShellRoute,

    // BUMDES routes - NO ShellRoute, StartPageBumdes has its own bottom nav
    ...BumdesRoutes.getRoutes(),

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
      path: RoutePaths.transactionHistory,
      name: RouteNames.transactionHistory,
      builder: (context, state) => const TransactionHistoryPage(),
    ),
    GoRoute(
      path: RoutePaths.checkout,
      name: RouteNames.checkout,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CheckoutPage(
          cart: extra?['cart'] ?? [],
          total: extra?['total'] ?? 0,
        );
      },
    ),
    GoRoute(
      path: RoutePaths.paymentWaiting,
      name: RouteNames.paymentWaiting,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return FadeTransitionPage(
          child: WaitingPaymentPage(
            orderId: extra?['order_id'],
            totalPayment: extra?['total'],
            orderNumber: extra?['order_number']?.toString(),
          ),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.paymentSuccess,
      name: RouteNames.paymentSuccess,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return FadeTransitionPage(
          child: PaymentConfirmedScreen(
            orderId: extra?['order_id']?.toString() ?? '',
            total: extra?['total'] ?? 0,
          ),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.paymentRejected,
      name: RouteNames.paymentRejected,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return FadeTransitionPage(
          child: PaymentRejectedScreen(
            orderId: extra?['order_id']?.toString() ?? '',
            total: extra?['total'] ?? 0,
          ),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.receipt,
      name: RouteNames.receipt,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final id = state.pathParameters['id'] ?? '';
        return FadeTransitionPage(
          child: ReceiptPage(
            orderId: extra?['order_id']?.toString() ?? id,
            total: extra?['total'] ?? 0,
            orderStatus: extra?['order_status']?.toString() ?? 'completed',
          ),
        );
      },
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

    // Product detail route (DINAMIS - :id parameter, shared for pembeli & bumdes)
    GoRoute(
      path: RoutePaths.productDetail,
      name: RouteNames.productDetail,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final id = state.pathParameters['id'];
        final productMap =
            extra ?? (id != null ? {'id': int.tryParse(id)} : null);

        // Check if this is for BUMDes (has 'isBumdes' flag)
        final isBumdes = productMap?['isBumdes'] == true;

        if (isBumdes) {
          // BUMDes product detail - with edit/delete capability
          return bumdes.ProductDetailPage(
            product: productMap ?? {},
            onUpdate: (_) {
              // Callback for updates - handled in screen
            },
          );
        } else {
          // Pembeli product detail - view only
          // Handle null productMap for invalid requests
          if (productMap == null || productMap['id'] == null) {
            // Invalid request - show error
            return Scaffold(
              appBar: AppBar(title: const Text('Produk')),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                    SizedBox(height: 16),
                    Text('Produk tidak ditemukan', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            );
          }
          return ProductDetailPage(product: productMap);
        }
      },
    ),

    // Chat route (shared for pembeli and bumdes)
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

    // Order tracking route (shared for pembeli and bumdes)
    GoRoute(
      path: RoutePaths.orderTracking,
      name: RouteNames.orderTracking,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final id = state.pathParameters['id'] ?? '';
        return OrderTrackingPage(
          order: extra ?? {'id': id},
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
                const SizedBox(height: 24),
                const Text(
                  'Halaman tidak ditemukan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  state.uri.toString(),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Check user role and navigate accordingly
                    final authState = context.read<AuthBloc>().state;
                    final role = authState.user?['role'];
                    
                    if (role == 'bumdes') {
                      context.go(RoutePaths.bumdesHome);
                    } else {
                      context.go(RoutePaths.pembeliHome);
                    }
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Kembali ke Beranda'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);

/// Custom Listenable that wraps a Stream to trigger router refresh
class GoRouterRefreshStream extends ChangeNotifier {
  late final Stream<dynamic> _stream;
  
  GoRouterRefreshStream(Stream<dynamic> stream) : _stream = stream {
    _stream.listen((_) => notifyListeners());
  }
}
