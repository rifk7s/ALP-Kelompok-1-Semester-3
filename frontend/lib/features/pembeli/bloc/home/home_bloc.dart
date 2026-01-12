import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:frontend/features/pembeli/bloc/home/home_event.dart';
import 'package:frontend/features/pembeli/bloc/home/home_state.dart';
import 'package:frontend/features/product/repository/category_repository.dart';
import 'package:frontend/features/product/repository/product_repository.dart';
import 'package:frontend/features/pembeli/repository/cart_repository.dart';
import 'package:frontend/features/shared/repository/notification_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository;
  final CartRepository _cartRepository;
  final NotificationRepository _notificationRepository;

  HomeBloc({
    required CategoryRepository categoryRepository,
    required ProductRepository productRepository,
    required CartRepository cartRepository,
    required NotificationRepository notificationRepository,
  })  : _categoryRepository = categoryRepository,
        _productRepository = productRepository,
        _cartRepository = cartRepository,
        _notificationRepository = notificationRepository,
        super(HomeInitial()) {
    on<HomeCategoriesLoadRequested>(_onCategoriesLoadRequested);
    on<HomeProductsLoadRequested>(_onProductsLoadRequested);
    on<HomeCategorySelected>(_onCategorySelected);
    on<HomeCartCountRequested>(_onCartCountRequested);
    on<HomeNotificationCountRequested>(_onNotificationCountRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomeReset>(_onReset);
  }

  void _onReset(HomeReset event, Emitter<HomeState> emit) {
    emit(HomeInitial());
  }

  Future<void> _onCategoriesLoadRequested(
    HomeCategoriesLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;

    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(categories: []));
    } else {
      emit(HomeLoading(isLoadingCategories: true));
    }

    try {
      final data = await _categoryRepository.getCategories();

      // Re-check the state after the async operation
      // This handles the race condition where products might have loaded first
      final newState = state;
      if (newState is HomeLoaded) {
        // Products loaded first, preserve them
        emit(newState.copyWith(categories: data));
      } else {
        // Categories loaded first (or both loading)
        emit(HomeLoaded(categories: data));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading categories: $e');
      }
      emit(
        HomeError(
          message: 'Gagal memuat kategori: $e',
          isCategoriesError: true,
        ),
      );
    }
  }

  Future<void> _onProductsLoadRequested(
    HomeProductsLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;

    if (event.showLoading) {
      if (currentState is HomeLoaded) {
        emit(currentState.copyWith(products: []));
      } else {
        emit(HomeLoading(isLoadingProducts: true));
      }
    }

    try {
      final data = await _productRepository.getProducts(
        categoryId: event.categoryId,
      );

      // Sort: active products first, sold_out at bottom
      data.sort((a, b) {
        if (a['status'] == 'active' && b['status'] == 'sold_out') return -1;
        if (a['status'] == 'sold_out' && b['status'] == 'active') return 1;
        return 0;
      });

      // Re-check the state after the async operation
      // This handles the race condition where categories might have loaded first
      final newState = state;
      if (newState is HomeLoaded) {
        // Categories loaded first, preserve them
        emit(
          newState.copyWith(
            products: data,
            selectedCategoryId: event.categoryId,
          ),
        );
      } else {
        // Products loaded first (or both loading)
        emit(HomeLoaded(products: data, selectedCategoryId: event.categoryId));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading products: $e');
      }
      emit(
        HomeError(message: 'Gagal memuat produk: $e', isCategoriesError: false),
      );
    }
  }

  void _onCategorySelected(
    HomeCategorySelected event,
    Emitter<HomeState> emit,
  ) {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    // Toggle category selection - if clicking the same category, deselect it
    // Otherwise, select the new category
    final newCategoryId = currentState.selectedCategoryId == event.categoryId
        ? null
        : event.categoryId;

    emit(currentState.copyWith(selectedCategoryId: newCategoryId));

    // Load products for selected category (null = all products)
    add(
      HomeProductsLoadRequested(categoryId: newCategoryId, showLoading: false),
    );
  }

  Future<void> _onCartCountRequested(
    HomeCartCountRequested event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    try {
      final cartData = await _cartRepository.getCart();
      if (cartData != null) {
        final items = cartData['items'] as List<dynamic>? ?? [];
        emit(currentState.copyWith(cartItemCount: items.length));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading cart count: $e');
      }
    }
  }

  Future<void> _onNotificationCountRequested(
    HomeNotificationCountRequested event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    try {
      final count = await _notificationRepository.getUnreadCount();
      emit(currentState.copyWith(unreadNotificationCount: count));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading notification count: $e');
      }
    }
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded) {
      // If not loaded yet, trigger full load
      add(const HomeCategoriesLoadRequested());
      add(const HomeProductsLoadRequested());
      return;
    }

    // Show loading state while keeping old data reference for fallback
    emit(const HomeLoading(isLoadingCategories: true, isLoadingProducts: true));

    try {
      // Refresh all data in parallel
      final results = await Future.wait([
        _categoryRepository.getCategories(),
        _productRepository.getProducts(categoryId: currentState.selectedCategoryId),
      ]);

      final categories = results[0];
      final products = results[1];

      // Sort products: active first, then sold_out
      products.sort((a, b) {
        if (a['status'] == 'active' && b['status'] == 'sold_out') return -1;
        if (a['status'] == 'sold_out' && b['status'] == 'active') return 1;
        return 0;
      });

      emit(
        HomeLoaded(
          categories: categories,
          products: products,
          selectedCategoryId: currentState.selectedCategoryId,
          cartItemCount: currentState.cartItemCount,
          unreadNotificationCount: currentState.unreadNotificationCount,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error refreshing home data: $e');
      }
      // Emit error state so UI shows retry button
      emit(
        const HomeError(
          message: 'Gagal memuat data. Periksa koneksi internet Anda.',
        ),
      );
    }
  }
}
