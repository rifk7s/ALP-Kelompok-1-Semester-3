import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/features/bumdes/bloc/product_list/product_list_event.dart';
import 'package:frontend/features/bumdes/bloc/product_list/product_list_state.dart';
import 'package:frontend/features/product/repository/product_repository.dart';

/// BLoC for BUMDes product listing screen
/// Handles loading, filtering, and searching products
class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final ProductRepository _productRepository;

  ProductListBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(const ProductListState()) {
    on<ProductListLoadRequested>(_onLoadRequested);
    on<ProductListFilterChanged>(_onFilterChanged);
    on<ProductListSearchChanged>(_onSearchChanged);
    on<ProductListReset>(_onReset);
  }

  Future<void> _onLoadRequested(
    ProductListLoadRequested event,
    Emitter<ProductListState> emit,
  ) async {
    if (event.showSpinner) {
      emit(state.copyWith(isLoading: true, hasError: false, errorMessage: null));
    }

    try {
      // Run API call and minimum delay in parallel for UX
      final productsFuture = _productRepository.getProducts(
        forceRefresh: event.forceRefresh,
      );
      final delayFuture = event.showSpinner
          ? Future.delayed(LoadingDelayConstants.standardList)
          : Future.value();

      final data = await productsFuture;
      await delayFuture;

      emit(state.copyWith(
        products: List<Map<String, dynamic>>.from(data),
        isLoading: false,
        hasError: false,
        errorMessage: null,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading products: $e');
      }
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onFilterChanged(
    ProductListFilterChanged event,
    Emitter<ProductListState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onSearchChanged(
    ProductListSearchChanged event,
    Emitter<ProductListState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onReset(
    ProductListReset event,
    Emitter<ProductListState> emit,
  ) {
    emit(const ProductListState());
  }
}
