import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/bumdes/screens/start_page_bumdes.dart';
import 'package:frontend/features/bumdes/screens/product_detail_screen.dart' as bumdes;
import 'package:frontend/features/bumdes/screens/upload_screen.dart';
import 'package:frontend/features/bumdes/screens/edit_product_screen.dart';
import 'package:frontend/features/bumdes/screens/petani/add_screen.dart';
import 'package:frontend/features/bumdes/screens/petani/detail_screen.dart';
import 'package:frontend/features/shared/screens/chat_detail_page.dart';
import 'package:frontend/core/router/route_constants.dart';

/// Bumdes feature routes using ShellRoute for bottom navigation
class BumdesRoutes {
  static RouteBase bumdesShellRoute = ShellRoute(
    builder: (context, state, child) {
      return _BumdesShell(child: child);
    },
    routes: [
      GoRoute(
        path: RoutePaths.bumdesHome,
        name: RouteNames.bumdesHome,
        builder: (context, state) => const StartPageBumdes(),
      ),
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
        path: RoutePaths.productDetail,
        name: RouteNames.productDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final id = state.pathParameters['id'];
          final productMap = extra ?? (id != null ? {'id': int.tryParse(id)} : {});
          return bumdes.ProductDetailPage(product: productMap, onUpdate: (_) {});
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
}

/// Shell widget for bumdes navigation
class _BumdesShell extends StatelessWidget {
  final Widget child;

  const _BumdesShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
