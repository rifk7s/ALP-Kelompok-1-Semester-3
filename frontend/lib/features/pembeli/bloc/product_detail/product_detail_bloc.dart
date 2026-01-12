import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:frontend/features/pembeli/bloc/product_detail/product_detail_event.dart';
import 'package:frontend/features/pembeli/bloc/product_detail/product_detail_state.dart';
import 'package:frontend/features/product/repository/product_repository.dart';
import 'package:frontend/features/pembeli/repository/cart_repository.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final ProductRepository _productRepository;
  final CartRepository _cartRepository;

  ProductDetailBloc({
    required ProductRepository productRepository,
    required CartRepository cartRepository,
  })  : _productRepository = productRepository,
        _cartRepository = cartRepository,
        super(ProductDetailInitial()) {
    on<ProductDetailLoadRequested>(_onLoadRequested);
    on<ProductDetailCartCountRequested>(_onCartCountRequested);
    on<ProductDetailQuantityChanged>(_onQuantityChanged);
    on<ProductDetailAddToCartRequested>(_onAddToCartRequested);
    on<ProductDetailStockValidated>(_onStockValidated);
  }

  Future<void> _onLoadRequested(
    ProductDetailLoadRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());

    try {
      final product = await _productRepository.getProductById(event.productId);

      if (product != null) {
        emit(ProductDetailLoaded(product: product));
      } else {
        emit(
          ProductDetailLoaded(
            product: {'id': event.productId}, // Fallback
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading product: $e');
      }
      emit(ProductDetailError('Gagal memuat produk: $e'));
    }
  }

  Future<void> _onCartCountRequested(
    ProductDetailCartCountRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductDetailLoaded) return;

    try {
      final cart = await _cartRepository.getCart();
      final cartItemCount = cart?['item_count'] ?? 0;

      // Get quantity of this product in cart
      final qtyInCart = _getQtyInCart(currentState.product['id']);

      emit(
        currentState.copyWith(
          cartItemCount: cartItemCount,
          qtyInCart: qtyInCart,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading cart count: $e');
      }
    }
  }

  void _onQuantityChanged(
    ProductDetailQuantityChanged event,
    Emitter<ProductDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is! ProductDetailLoaded) return;

    final available = currentState.availableStock;
    final newQty = event.newQty < 1 ? 1 : event.newQty;

    if (newQty > available) {
      emit(
        ProductDetailStockValidation(
          isValid: false,
          errorMessage: currentState.qtyInCart > 0
              ? 'Jumlah melebihi stok. Anda sudah punya ${currentState.qtyInCart.toInt()} kg di keranjang. Maksimal tambah ${available.toInt()} kg lagi'
              : 'Jumlah melebihi stok. Maksimal ${currentState.stockKg.toInt()} kg',
        ),
      );
      // Revert to previous state
      emit(currentState);
      return;
    }

    emit(currentState.copyWith(selectedQty: newQty));
  }

  Future<void> _onAddToCartRequested(
    ProductDetailAddToCartRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductDetailLoaded) return;

    emit(ProductDetailAddingToCart());

    try {
      // Fetch fresh stock from database
      final freshProduct = await _productRepository.getProductById(event.productId);

      if (freshProduct == null) {
        emit(const ProductDetailError('Produk tidak ditemukan'));
        emit(currentState);
        return;
      }

      final dbStockKg =
          double.tryParse(freshProduct['stock_kg']?.toString() ?? '0') ?? 0;

      // Validate stock including cart quantity
      final qtyInCart = await _getQtyInCartAsync(event.productId);
      final available = dbStockKg - qtyInCart;

      if (dbStockKg <= 0) {
        emit(const ProductDetailError('Produk stok habis'));
        emit(currentState);
        return;
      }

      if (event.quantityKg > available) {
        emit(
          ProductDetailError(
            qtyInCart > 0
                ? 'Stok tidak cukup. Anda sudah memiliki ${qtyInCart.toInt()} kg di keranjang. Stok tersisa ${available.toInt()} kg'
                : 'Jumlah melebihi stok tersedia (${dbStockKg.toInt()} kg)',
          ),
        );
        emit(currentState);
        return;
      }

      // Add to cart via backend
      final success = await _cartRepository.addToCart(
        productId: event.productId,
        quantityKg: event.quantityKg,
      );

      if (success) {
        // Reload cart count
        final cart = await _cartRepository.getCart();
        final newCartCount = cart?['item_count'] ?? 0;

        // Calculate new available stock
        final newQtyInCart = await _getQtyInCartAsync(event.productId);

        emit(
          currentState.copyWith(
            cartItemCount: newCartCount,
            qtyInCart: newQtyInCart,
          ),
        );

        // Emit added to cart state for UI feedback
        emit(ProductDetailAddedToCart(newCartCount));

        // Return to loaded state without triggering full reload
        emit(
          currentState.copyWith(
            cartItemCount: newCartCount,
            qtyInCart: newQtyInCart,
          ),
        );
      } else {
        emit(const ProductDetailError('Gagal menambahkan ke keranjang'));
        emit(currentState);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding to cart: $e');
      }
      emit(ProductDetailError('Gagal menambahkan ke keranjang: $e'));
      emit(currentState);
    }
  }

  Future<void> _onStockValidated(
    ProductDetailStockValidated event,
    Emitter<ProductDetailState> emit,
  ) async {
    try {
      final freshProduct = await _productRepository.getProductById(event.productId);

      if (freshProduct == null) {
        emit(
          const ProductDetailStockValidation(
            isValid: false,
            errorMessage: 'Produk tidak ditemukan',
          ),
        );
        return;
      }

      final dbStockKg =
          double.tryParse(freshProduct['stock_kg']?.toString() ?? '0') ?? 0;

      if (dbStockKg <= 0) {
        emit(
          const ProductDetailStockValidation(
            isValid: false,
            errorMessage: 'Produk stok habis',
          ),
        );
        return;
      }

      if (event.desiredQty > dbStockKg) {
        emit(
          ProductDetailStockValidation(
            isValid: false,
            errorMessage:
                'Jumlah melebihi stok tersedia (${dbStockKg.toInt()} kg)',
          ),
        );
        return;
      }

      emit(const ProductDetailStockValidation(isValid: true));
    } catch (e) {
      emit(
        ProductDetailStockValidation(
          isValid: false,
          errorMessage: 'Gagal memvalidasi stok: $e',
        ),
      );
    }
  }

  double _getQtyInCart(int productId) {
    // This should be called from state, returns cached value
    final currentState = state;
    if (currentState is ProductDetailLoaded) {
      return currentState.qtyInCart;
    }
    return 0;
  }

  Future<double> _getQtyInCartAsync(int productId) async {
    try {
      final cart = await _cartRepository.getCart();
      if (cart == null) return 0;

      final items = cart['items'] as List<dynamic>? ?? [];
      for (var item in items) {
        if (item['product_id'] == productId) {
          return double.parse(item['quantity_kg'].toString());
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting qty in cart: $e');
      }
    }
    return 0;
  }
}
