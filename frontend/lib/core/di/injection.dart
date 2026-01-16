import 'dart:async';

import 'package:flutter/foundation.dart';
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

/// Mutex to prevent race conditions in scope operations
Completer<void>? _scopeOperationLock;

/// Setup base dependencies (called once at app start)
/// These persist across login/logout cycles
void setupLocator() {
  // ==================== Base Scope ====================
  // Core repositories that don't hold user-specific data
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerLazySingleton<ProductRepository>(() => ProductRepository());
  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepository());

  // BUMDes repositories (BUMDes has separate session management)
  sl.registerLazySingleton<BumdesRepository>(() => BumdesRepository());
  sl.registerLazySingleton<PetaniRepository>(() => PetaniRepository());

  // AuthBloc in base scope (manages auth state across app lifecycle)
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(repository: sl<AuthRepository>()),
  );
}

/// Push authenticated scope after login
/// Creates fresh instances for user-specific data
/// Uses mutex to prevent race conditions from concurrent calls
Future<void> pushAuthenticatedScope() async {
  // Wait for any pending scope operation to complete
  if (_scopeOperationLock != null && !_scopeOperationLock!.isCompleted) {
    debugPrint('🔐 Waiting for pending scope operation...');
    await _scopeOperationLock!.future;
  }

  // Don't push if already in authenticated scope
  if (sl.hasScope('authenticated')) {
    debugPrint('🔐 Authenticated scope already exists, skipping push');
    return;
  }

  // Acquire lock
  _scopeOperationLock = Completer<void>();

  try {
    sl.pushNewScope(
      scopeName: 'authenticated',
      init: (getIt) {
        debugPrint('🔐 Pushing authenticated scope');

        // User-specific repositories (fresh per session)
        getIt.registerLazySingleton<CartRepository>(() => CartRepository());
        getIt.registerLazySingleton<OrderRepository>(() => OrderRepository());
        getIt.registerLazySingleton<NotificationRepository>(
          () => NotificationRepository(),
        );

        // User-specific BLoCs (fresh per session)
        getIt.registerLazySingleton<CartBloc>(
          () => CartBloc(
            cartRepository: getIt<CartRepository>(),
            productRepository: sl<ProductRepository>(),
          ),
        );
        getIt.registerLazySingleton<HomeBloc>(
          () => HomeBloc(
            categoryRepository: sl<CategoryRepository>(),
            productRepository: sl<ProductRepository>(),
            cartRepository: getIt<CartRepository>(),
            notificationRepository: getIt<NotificationRepository>(),
          ),
        );
        getIt.registerLazySingleton<ProductDetailBloc>(
          () => ProductDetailBloc(
            productRepository: sl<ProductRepository>(),
            cartRepository: getIt<CartRepository>(),
          ),
        );
      },
      dispose: () async {
        debugPrint('🔐 Disposing authenticated scope');
      },
    );
  } finally {
    // Release lock
    _scopeOperationLock!.complete();
  }
}

/// Pop authenticated scope on logout
/// Cleans up all user-specific instances
/// Uses mutex to prevent race conditions from concurrent calls
Future<void> popAuthenticatedScope() async {
  // Wait for any pending scope operation to complete
  if (_scopeOperationLock != null && !_scopeOperationLock!.isCompleted) {
    debugPrint('🔐 Waiting for pending scope operation...');
    await _scopeOperationLock!.future;
  }

  if (!sl.hasScope('authenticated')) {
    debugPrint('🔐 No authenticated scope to pop');
    return;
  }

  // Acquire lock
  _scopeOperationLock = Completer<void>();

  try {
    await sl.popScope();
    debugPrint('🔐 Authenticated scope popped');
  } finally {
    // Release lock
    _scopeOperationLock!.complete();
  }
}

/// Check if authenticated scope is active
bool hasAuthenticatedScope() => sl.hasScope('authenticated');

/// Reset all registered instances (useful for testing or full reset)
Future<void> resetLocator() async {
  await sl.reset();
  setupLocator();
}
