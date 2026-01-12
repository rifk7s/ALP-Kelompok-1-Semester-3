import 'package:get_it/get_it.dart';

// Repositories
import 'package:frontend/features/auth/repository/auth_repository.dart';
import 'package:frontend/features/product/repository/product_repository.dart';
import 'package:frontend/features/product/repository/category_repository.dart';
import 'package:frontend/features/pembeli/repository/cart_repository.dart';
import 'package:frontend/features/pembeli/repository/order_repository.dart';
import 'package:frontend/features/bumdes/repository/bumdes_repository.dart';
import 'package:frontend/features/bumdes/repository/petani_repository.dart';
import 'package:frontend/features/shared/repository/notification_repository.dart';

// BLoCs
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'package:frontend/features/pembeli/bloc/cart/cart_bloc.dart';
import 'package:frontend/features/pembeli/bloc/home/home_bloc.dart';
import 'package:frontend/features/pembeli/bloc/product_detail/product_detail_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Setup all dependencies
/// Call this in main() before runApp()
void setupLocator() {
  // ==================== Repositories ====================
  // Lazy singletons - created on first access, same instance reused
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerLazySingleton<ProductRepository>(() => ProductRepository());
  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepository());
  sl.registerLazySingleton<CartRepository>(() => CartRepository());
  sl.registerLazySingleton<OrderRepository>(() => OrderRepository());
  sl.registerLazySingleton<BumdesRepository>(() => BumdesRepository());
  sl.registerLazySingleton<PetaniRepository>(() => PetaniRepository());
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(),
  );

  // ==================== BLoCs ====================
  // Singletons for global BLoCs that persist across the app
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(repository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton<CartBloc>(
    () => CartBloc(
      cartRepository: sl<CartRepository>(),
      productRepository: sl<ProductRepository>(),
    ),
  );

  sl.registerLazySingleton<HomeBloc>(
    () => HomeBloc(
      categoryRepository: sl<CategoryRepository>(),
      productRepository: sl<ProductRepository>(),
      cartRepository: sl<CartRepository>(),
      notificationRepository: sl<NotificationRepository>(),
    ),
  );

  sl.registerLazySingleton<ProductDetailBloc>(
    () => ProductDetailBloc(
      productRepository: sl<ProductRepository>(),
      cartRepository: sl<CartRepository>(),
    ),
  );
}

/// Reset all registered instances (useful for logout)
Future<void> resetLocator() async {
  await sl.reset();
  setupLocator();
}
