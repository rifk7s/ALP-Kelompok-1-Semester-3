import 'package:go_router/go_router.dart';
import 'package:frontend/features/bumdes/screens/start_page_bumdes.dart';
import 'package:frontend/features/bumdes/screens/upload_screen.dart';
import 'package:frontend/features/bumdes/screens/edit_product_screen.dart';
import 'package:frontend/features/bumdes/screens/petani/add_screen.dart';
import 'package:frontend/features/bumdes/screens/petani/detail_screen.dart';
import 'package:frontend/core/router/route_constants.dart';

/// Bumdes feature routes - NO ShellRoute, using direct GoRoute
/// StartPageBumdes already has its own bottom navigation
class BumdesRoutes {
  static List<RouteBase> getRoutes() {
    return [
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
    ];
  }
}

