import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:frontend/features/pembeli/bloc/cart/cart_event.dart';
import 'package:frontend/features/pembeli/bloc/cart/cart_state.dart';
import 'package:frontend/core/services/cart_service.dart';
import 'package:frontend/core/services/product_service.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  int _lastQtyChangeClick = 0;

  CartBloc() : super(CartInitial()) {
    on<CartLoadRequested>(_onLoadRequested);
    on<CartItemQuantityChanged>(_onQuantityChanged);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartItemSelectedToggled>(_onItemSelectedToggled);
    on<CartSelectAllToggled>(_onSelectAllToggled);
    on<CartRecommendationsLoadRequested>(_onRecommendationsLoadRequested);
    on<CartStockValidated>(_onStockValidated);
  }

  Future<void> _onLoadRequested(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    if (event.showSpinner) {
      emit(const CartLoading());
    }

    try {
      final cart = await CartService.getCart();
      if (kDebugMode) {
        debugPrint('Cart response: $cart');
      }

      if (cart != null) {
        final items = cart['items'] ?? [];
        if (kDebugMode) {
          debugPrint('Cart items count: ${items.length}');
        }

        final currentState = state;
        final previousSelection = currentState is CartLoaded
            ? Map<int, bool>.from(currentState.selectedItems)
            : {};

        final selectedItems = <int, bool>{
          for (var item in items)
            item['id'] as int: previousSelection[item['id']] ?? false,
        };

        final selectAll =
            selectedItems.values.isNotEmpty &&
            selectedItems.values.every((val) => val);

        emit(
          CartLoaded(
            cartItems: List<Map<String, dynamic>>.from(items),
            subtotal: cart['subtotal'] ?? 0,
            shippingCost: cart['shipping_cost'] ?? 0,
            total: cart['total'] ?? 0,
            selectedItems: selectedItems,
            selectAll: selectAll,
            recommendations: currentState is CartLoaded
                ? currentState.recommendations
                : [],
          ),
        );
      } else {
        if (kDebugMode) {
          debugPrint('Cart is null');
        }
        emit(CartLoaded());
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading cart: $e');
      }
      emit(CartError('Gagal memuat keranjang: $e'));
    }
  }

  Future<void> _onQuantityChanged(
    CartItemQuantityChanged event,
    Emitter<CartState> emit,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastQtyChangeClick < 300) return;

    final currentState = state;
    if (currentState is! CartLoaded) return;

    final item = event.item;
    if (currentState.updatingItems.contains(item['id'])) return;
    _lastQtyChangeClick = now;

    // Check stock before allowing increase
    final product = item['product'];
    final stockKg =
        double.tryParse(product['stock_kg']?.toString() ?? '0') ?? 0;
    final currentQty = double.parse(item['quantity_kg'].toString());

    if (event.newQty > currentQty && event.newQty > stockKg) {
      emit(
        CartError(
          'Stok tidak mencukupi. Stok tersedia: ${stockKg.toStringAsFixed(0)} kg',
        ),
      );
      // Revert to previous state
      emit(currentState);
      return;
    }

    emit(
      currentState.copyWith(
        updatingItems: {...currentState.updatingItems, item['id']},
      ),
    );

    try {
      if (event.newQty <= 0) {
        await CartService.removeFromCart(item['id']);
      } else {
        final success = await CartService.updateCartItem(
          cartId: item['id'],
          quantityKg: event.newQty,
        );

        if (!success) {
          emit(CartError('Gagal mengubah jumlah'));
          emit(currentState);
          return;
        }
      }

      // Reload cart
      add(const CartLoadRequested(showSpinner: false));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error changing quantity: $e');
      }
      emit(CartError('Gagal mengubah jumlah: $e'));
      emit(currentState);
    }
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    try {
      final success = await CartService.removeFromCart(event.cartId);
      if (!success) {
        emit(CartError('Gagal menghapus item'));
        return;
      }
      add(const CartLoadRequested(showSpinner: false));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error removing item: $e');
      }
      emit(CartError('Gagal menghapus item: $e'));
    }
  }

  void _onItemSelectedToggled(
    CartItemSelectedToggled event,
    Emitter<CartState> emit,
  ) {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final newSelectedItems = <int, bool>{...currentState.selectedItems};
    newSelectedItems[event.itemId] = event.isSelected;

    final selectAll =
        newSelectedItems.values.isNotEmpty &&
        newSelectedItems.values.every((val) => val);

    emit(
      currentState.copyWith(
        selectedItems: newSelectedItems,
        selectAll: selectAll,
      ),
    );
  }

  void _onSelectAllToggled(
    CartSelectAllToggled event,
    Emitter<CartState> emit,
  ) {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final newSelectedItems = <int, bool>{
      for (var item in currentState.cartItems)
        item['id'] as int: event.selectAll,
    };

    emit(
      currentState.copyWith(
        selectedItems: newSelectedItems,
        selectAll: event.selectAll,
      ),
    );
  }

  Future<void> _onRecommendationsLoadRequested(
    CartRecommendationsLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    try {
      final products = await ProductService.getProducts();
      final productsWithStock = products
          .where((p) {
            final stockKg =
                double.tryParse(p['stock_kg']?.toString() ?? '0') ?? 0;
            return stockKg > 0;
          })
          .toList()
          .cast<Map<String, dynamic>>();

      productsWithStock.shuffle();

      final currentState = state;
      if (currentState is CartLoaded) {
        emit(
          currentState.copyWith(
            recommendations: productsWithStock.take(3).toList(),
          ),
        );
      } else {
        // Emit a CartLoaded state with recommendations even if cart is empty
        emit(CartLoaded(recommendations: productsWithStock.take(3).toList()));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading recommendations: $e');
      }
      // If there's an error, still emit a state with empty recommendations
      final currentState = state;
      if (currentState is CartLoaded) {
        emit(currentState.copyWith(recommendations: []));
      } else {
        emit(const CartLoaded(recommendations: []));
      }
    }
  }

  Future<void> _onStockValidated(
    CartStockValidated event,
    Emitter<CartState> emit,
  ) async {
    // Save current state before validation
    final currentState = state;
    if (currentState is! CartLoaded) return;

    bool stockValid = true;
    String? errorMsg;

    for (final item in event.selectedItems) {
      final product = item['product'];
      final productId = product['id'];
      final cartQty = double.parse(item['quantity_kg'].toString());

      try {
        final freshProduct = await ProductService.getProductById(productId);

        if (freshProduct == null) {
          stockValid = false;
          errorMsg = 'Produk "${product['name']}" tidak ditemukan';
          break;
        }

        final dbStockKg =
            double.tryParse(freshProduct['stock_kg']?.toString() ?? '0') ?? 0;

        if (dbStockKg <= 0) {
          stockValid = false;
          errorMsg =
              'Produk "${product['name']}" stok habis. Silakan hapus dari keranjang.';
          break;
        }

        if (cartQty > dbStockKg) {
          stockValid = false;
          errorMsg =
              'Jumlah "${product['name']}" (${cartQty.toStringAsFixed(0)} kg) melebihi stok tersedia (${dbStockKg.toStringAsFixed(0)} kg). Silakan kurangi jumlah.';
          break;
        }
      } catch (e) {
        stockValid = false;
        errorMsg = 'Gagal memeriksa stok "${product['name']}". Coba lagi.';
        break;
      }
    }

    emit(
      CartStockValidationResult(isValid: stockValid, errorMessage: errorMsg),
    );

    // Restore the original CartLoaded state with all selections intact
    emit(currentState);
  }
}
